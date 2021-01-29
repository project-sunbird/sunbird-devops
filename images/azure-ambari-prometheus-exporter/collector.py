import os
import json
import yaml
import re
import time
import logging
import datetime
from pytz import timezone
from datetime import timedelta,date
from prometheus_client import start_http_server
from prometheus_client.core import GaugeMetricFamily, REGISTRY
from expiringdict import ExpiringDict
import requests

LOGLEVEL = os.getenv('LOGLEVEL', 'INFO').upper()
logging.basicConfig(
    format='%(asctime)s - %(levelname)s - %(message)s'
    , datefmt='%m/%d/%Y %I:%M:%S %p'
    , level=LOGLEVEL
)

BATCH_DELAY = os.getenv('BATCH_DELAY', 60)
CONF_FILE = os.getenv('CONF_FILE', 'conf/components.yaml')



class AmbariMetricCollector(object):
    def __init__(self, conf_file):
        self.cache = ExpiringDict(max_len=10000, max_age_seconds=86400)
        self.prom_metrics = {}
        self.host = {}	
        self.ambari_info = {
            'AMBARI_USER': os.getenv('AMBARI_USER')
            , 'AMBARI_PASS': os.getenv('AMBARI_PASS')
        }

        with open(conf_file, "r") as read_conf_file:
            conf = yaml.load(read_conf_file)

        self.conf_nn, self.conf_rm, self.conf_alert, self.conf_apphistory = self._parse_conf(conf)

    def _parse_conf(self, conf):
        conf_nn = conf.get('namenode', None)
        conf_rm = conf.get('resourcemanager', None)
        conf_alert = conf.get('ambari_alert', None)
        conf_apphistory= conf.get('ambari_apphistory', None)

        return conf_nn, conf_rm, conf_alert, conf_apphistory

    def _parse_metrics(self, data, prefix, metrics): 		
        for k, v in data.items():
            if type(v) is dict:
                prefix.append(k)
                self._parse_metrics(v, prefix, metrics)
                if len(prefix) > 0:
                    prefix.pop(len(prefix) - 1)
            else:	
                metric_name = '{}_{}'.format('_'.join(prefix), k)

                if type(v) is int or type(v) is float:
                    metrics[metric_name] = v

    def _parse_cluster_metrics(self, data, prefix, metrics, host): 
        for k, v in data.items():
            if k in ('HostRoles'):
                  host['component_name'] = str(v['component_name'])
                  host['host_name']= v['host_name'].replace(".", "_").replace("-", "_")
            elif type(v) is dict:
                prefix.append(k)
                self._parse_cluster_metrics(v, prefix, metrics, host)
                if len(prefix) > 0:
                    prefix.pop(len(prefix) - 1)
            else:
                metric_name = '{}_{}'.format('_'.join(prefix), k)
                if type(v) is int or type(v) is float:
                    if bool(host) :
                       prom_metric = GaugeMetricFamily(metric_name, metric_name, labels=['component_name','host_name'])
                       prom_metric.add_metric([host['component_name'],host['host_name']],v)
                       metric_name +=(host['host_name'])
                       metrics[metric_name] = prom_metric

    def _parse_with_filter(self, data, prefix, metrics, conf):
        new_metrics = {}
        self._parse_metrics(data, prefix, new_metrics)

        if conf.get('white_list', None):
            self._filter_metric_in_white_list(new_metrics, conf.get('white_list', None))
        elif conf.get('black_list', None):
            self._filter_metric_in_black_list(new_metrics, conf.get('black_list', None))

        metrics.update(new_metrics)

    def _parse_with_clusterfilter(self, data, prefix, metrics, conf):
        new_metrics = {}
        host = {}
        self._parse_cluster_metrics(data, prefix, new_metrics, host)

        if conf.get('white_list', None):
            self._filter_metric_in_white_list(new_metrics, conf.get('white_list', None))
        elif conf.get('black_list', None):
            self._filter_metric_in_black_list(new_metrics, conf.get('black_list', None))

        self.prom_metrics.update(new_metrics)
        metrics.update(new_metrics)

    def _parse_apphistory_metrics(self, data, prefix, app_id, metrics,group_metric):
        for k, v in data.items():
            if type(v) is dict:
                prefix.append(k)
                self._parse_metrics(v, prefix, metrics)
                if len(prefix) > 0:
                    prefix.pop(len(prefix) - 1)
            else:
                if len(prefix) > 0:
                    metric_name = '{}_{}'.format('_'.join(prefix), k)
                else:
                    metric_name = k

                if type(v) is int or type(v) is float:
                    prom_metric = GaugeMetricFamily(metric_name, metric_name, labels=list(group_metric.keys()))
                    prom_metric.add_metric(list(group_metric.values()),v)
                    metric_name += app_id
                    metric_name += str(group_metric['stageId'])
                    metrics[metric_name] = prom_metric

    def _parse_apphistory_with_filter(self, data, prefix, app_id, group_metric, metrics, conf):
        new_metrics = {}
        host = {}
        self._parse_apphistory_metrics(data, prefix, app_id, new_metrics, group_metric)

        if conf.get('white_list', None):
            self._filter_metric_in_white_list(new_metrics, conf.get('white_list', None))
        elif conf.get('black_list', None):
            self._filter_metric_in_black_list(new_metrics, conf.get('black_list', None))
        for k,v in new_metrics.items():
            if(len(self.cache) == 0 or k not in self.cache.keys()):
              self.cache[k] = v
              self.prom_metrics[k] = v
              metrics[k] = v
            else:
              #self.prom_metrics.pop(k,'No Key found')
              metrics.pop(k,'No Key found')
    
    def _filter_by_rule(self, metrics, rules, is_wl=True):
        if rules is None:
            return

        remove_metrics = []
        for k, v in metrics.items():
            if is_wl:
                remove = True
                for bl in rules:
                    if re.search(bl, k):
                        remove = False
                        break

                if remove:
                    remove_metrics.append(k)
            else:
                for bl in rules:
                    if re.search(bl, k):
                        remove_metrics.append(k)
                        break

        for rm in remove_metrics:
            if rm in metrics:
                del metrics[rm]

    def _filter_metric_in_black_list(self, metrics, metrics_bl=None):
        self._filter_by_rule(metrics, metrics_bl, is_wl=False)

    def _filter_metric_in_white_list(self, metrics, metrics_wl=None):
        self._filter_by_rule(metrics, metrics_wl, is_wl=True)

    def _collect_ambari_alerts(self, metrics):
        try:
            ambari_alert_url = os.getenv('AMBARI_ALERT_URL', '')	
            data = self._call_ambari_api(ambari_alert_url)
        except Exception as e:
            logging.error('Call Ambari API error.\n {}'.format(e))

            return

        self._parse_with_filter(data['alerts_summary'], ['ambari_alert'], metrics, self.conf_alert)

    def _collect_namenode_metrics(self, metrics):
        try:
            ambari_metrics_url = os.getenv('AMBARI_METRICS_URL', '')
            data = self._call_json_api(ambari_metrics_url)
        except Exception as e:
            logging.error('Call Namenode JMX error.\n {}'.format(e))

            return

        for item in data['items']:
          self._parse_with_clusterfilter(item, ['cluster'], metrics, self.conf_nn)

    def _collect_resourcemanager_metrics(self, metrics):
        try:
            data = self._call_json_api(os.getenv('AMBARI_RM_URL', ''), headers={'Accept': 'application/json'})
        except Exception as e:
            logging.error('Call Resource Manager metrics error.\n {}'.format(e))
            return

        if not data.get('clusterMetrics'):
            return

        self._parse_with_filter(data['clusterMetrics'], ['resourcemanager'], metrics, self.conf_rm)

    def _collect_apphistory_metrics(self, metrics):
            group_metric={}
            date_today = (int(date.today().strftime('%s')) * 1000)
            try:
                url = self.conf_apphistory['url']+'?minDate='+(datetime.datetime.now(timezone('GMT'))-datetime.timedelta(minutes = 10)).strftime('%Y-%m-%dT%H:%M:%S.000GMT')+'&maxDate='+(datetime.datetime.now(timezone('GMT'))+datetime.timedelta(minutes = 10)).strftime('%Y-%m-%dT%H:%M:%S.000GMT')
                data = self._call_json_api(url)
            except Exception as e:
                logging.error('Call Namenode JMX error.\n {}'.format(e))
                return
            for item in data:
               latest_attempt =  len(item['attempts'])
               if item['attempts'][latest_attempt-1]['endTimeEpoch'] >= date_today:
                 app_data= self._call_json_api(os.getenv('AMBARI_APPHISTORY_URL', '')+r"/"+item['id']+r"/"+str(latest_attempt)+r"/"+"stages")
                 group_metric['appname'] = item['name'].replace(" ", "")
                 for data_item in app_data :
                   data_item['reportDate'] = item['attempts'][latest_attempt-1]['lastUpdated']
                   data_item['timeTaken']= item['attempts'][latest_attempt-1]['duration']
                   for label in self.conf_apphistory['labels']:
                     group_metric[label]= str(data_item[label])
                   self._parse_apphistory_with_filter(data_item,[] ,item['id'], group_metric , metrics, self.conf_apphistory) 

    def _collect(self):
        metrics = {}
        labels = {}
        host = {}
        self._collect_resourcemanager_metrics(metrics)
        self._collect_ambari_alerts(metrics)
        self._collect_namenode_metrics(metrics)
        self._collect_apphistory_metrics(metrics)

        for k, v in metrics.items():
             prom_metric = self.prom_metrics.get(k, None)
             if not prom_metric:
                prom_metric = GaugeMetricFamily(k, k, labels=['cluster_name', 'component_name', 'host_name'])
                self.prom_metrics[k] = prom_metric
                prom_metric.add_metric(list(labels.values()), v)

    def collect(self):
        logging.info('Start fetching metrics')
        self._collect()
        logging.info('Finish fetching metrics')
        for m in list(self.prom_metrics.values()):
           yield m

    def _call_ambari_api(self, url):
        """
        Call Ambari's API to return json data
        Sample curl
        curl -k \
        -u username:password \
        -H 'X-Requested-By: ambari' \
        -X GET \
        "https://localhost:8080/api/v1/clusters/trustingsocial/host_components?fields=metrics/*"
        """

        ambari_info = self.ambari_info

        response = requests.get(
            url
            , auth=(ambari_info['AMBARI_USER'], ambari_info['AMBARI_PASS'])
            , headers={'X-Requested-By': 'ambari'}
            , verify=False
        )

        if response.status_code != requests.codes.ok:
            return {}
        return response.json()

    def _call_json_api(self, url, headers={}):
        ambari_info = self.ambari_info
        response = requests.get(url, auth=(ambari_info['AMBARI_USER'], ambari_info['AMBARI_PASS']), headers=headers)
        	
        if response.status_code != requests.codes.ok:
            return {}
        return response.json()


if __name__ == "__main__":
    collector = AmbariMetricCollector(CONF_FILE)

    REGISTRY.register(collector)
    start_http_server(9999)
    while True:
        time.sleep(1)

