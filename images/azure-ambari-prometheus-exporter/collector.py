import os
import json
import yaml
import re
import time
import logging
from prometheus_client import start_http_server
from prometheus_client.core import GaugeMetricFamily, REGISTRY
import requests

LOGLEVEL = os.getenv('LOGLEVEL', 'INFO').upper()
logging.basicConfig(
    format='%(asctime)s - %(levelname)s - %(message)s'
    , datefmt='%m/%d/%Y %I:%M:%S %p'
    , level=LOGLEVEL
)

try:
    from statsd.defaults.env import statsd
except Exception as e:
    logging.error(e)

BATCH_DELAY = os.getenv('BATCH_DELAY', 60)
CONF_FILE = os.getenv('CONF_FILE', 'src/components.yaml')



class AmbariMetricCollector(object):
    def __init__(self, conf_file):
        self.prom_metrics = {}
        self.host = {}	
        self.statsd_metrics = {}
        self.ambari_info = {
            'AMBARI_USER': os.getenv('AMBARI_USER')
            , 'AMBARI_PASS': os.getenv('AMBARI_PASS')
        }

        with open(conf_file, "r") as read_conf_file:
            conf = yaml.load(read_conf_file)

        self.conf_nn, self.conf_rm, self.conf_alert = self._parse_conf(conf)

    def _parse_conf(self, conf):
        conf_nn = conf.get('namenode', None)
        conf_rm = conf.get('resourcemanager', None)
        conf_alert = conf.get('ambari_alert', None)

        return conf_nn, conf_rm, conf_alert

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
                       print('in host', host['component_name']) 
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
            ambari_rm_url = os.getenv('AMBARI_RM_URL', '')
            data = self._call_json_api(os.getenv('AMBARI_RM_URL', ''), headers={'Accept': 'application/json'})
        except Exception as e:
            logging.error('Call Resource Manager metrics error.\n {}'.format(e))

            return

        if not data.get('clusterMetrics'):
            return

        self._parse_with_filter(data['clusterMetrics'], ['resourcemanager'], metrics, self.conf_rm)

    def _collect(self):
        metrics = {}
        labels = {}
        host = {}
        self._collect_resourcemanager_metrics(metrics)
        self._collect_ambari_alerts(metrics)
        self._collect_namenode_metrics(metrics)   
        for k, v in metrics.items():
             prom_metric = self.prom_metrics.get(k, None)	
             if not prom_metric:
                prom_metric = GaugeMetricFamily(k, k, labels=['cluster_name', 'component_name', 'host_name'])
                self.prom_metrics[k] = prom_metric
                prom_metric.add_metric(list(labels.values()), v)
             self.statsd_metrics[k] = v
        


    def collect(self):
        logging.info('Start fetching metrics')
        self._collect()
        logging.info('Finish fetching metrics')

        for m in list(self.prom_metrics.values()):
            yield m

        logging.info('Send metrics to STATSD')
        for k, v in self.statsd_metrics.items():
            try:
                #print(k, '=>', v) 
                statsd.gauge(k, v)
            except Exception as e:
                logging.error('Send metrics to STATSD error.\n {}'.format(e))

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

    if os.getenv('DEV', 'FALSE') == 'TRUE':
        collector.collect()
    else:
        while True:
            collector.collect()
            logging.info('Sleep {} s'.format(str(BATCH_DELAY)))
            time.sleep(int(BATCH_DELAY))
