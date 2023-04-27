import argparse, sys
from collections import OrderedDict
import csv
import yaml

def setup_yaml():
  """ https://stackoverflow.com/a/31609484/69362 """
  represent_dict_order = lambda self, data:  self.represent_mapping('tag:yaml.org,2002:map', data.items())
  yaml.add_representer(OrderedDict, represent_dict_order)

def convert_csv_to_yaml(apis_csv_file):
    reader = csv.DictReader(apis_csv_file, delimiter=',')
    apis = []
    for row in reader:
        apis.append(OrderedDict([
            ('name', row['NAME']),
            ('request_path', row['REQUEST PATH']),
            ('upstream_url', row['UPSTREAM PATH']),
            ('strip_request_path', True),
            ('plugins', [
                OrderedDict([('name', 'jwt')]),
                OrderedDict([('name', 'cors')]),
                "{{ statsd_pulgin }}",
                OrderedDict([('name', 'acl'), ('config.whitelist', row["WHITELIST GROUP"])]),
                OrderedDict([('name', 'rate-limiting'), ('config.hour', row["RATE LIMIT"]), ('config.limit_by', row["LIMIT BY"])]),
                OrderedDict([('name', 'request-size-limiting'), ('config.allowed_payload_size', row["REQUEST SIZE LIMIT"])]),
            ])
        ]))
    yaml.dump(apis, sys.stdout, default_flow_style=False)

if  __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Converts APIs CSV to yaml that can be used in ansible')
    parser.add_argument('apis_csv_file_path', help='Path of the csv file containing apis data')
    args = parser.parse_args()
    setup_yaml()
    with open(args.apis_csv_file_path) as apis_csv_file:
        convert_csv_to_yaml(apis_csv_file)
