Ansible Filebeat role
=========

[![Ansible Galaxy](https://img.shields.io/badge/galaxy-DavidWittman.filebeat-blue.svg?style=flat)](https://galaxy.ansible.com/detail#/role/6293) [![Travis](https://travis-ci.org/DavidWittman/ansible-filebeat.svg?branch=master)](https://travis-ci.org/DavidWittman/ansible-filebeat)

Installs Elastic's Filebeat for forwarding logs.

Role Variables
--------------

 - `filebeat_version` - The version of filebeat to install. Defaults to `1.3.1`.
 - `filebeat_config` - YAML representation of your filebeat config. This is templated directly into the configuration file as YAML. See the [example configuration](https://github.com/elastic/beats/blob/master/filebeat/filebeat.full.yml) for an exhaustive list of configuration options. Defaults to:

  ``` yaml
  filebeat_config:
    filebeat:
      prospectors:
        - paths:
            - /var/log/messages
            - /var/log/*.log
          input_type: log
    output:
      file:
        path: /tmp/filebeat
        filename: filebeat
    logging:
      to_syslog: true
      level: error
  ```
 - `filebeat_ca_cert` - If provided, the contents of this variable will be placed into the file identified by `filebeat_ca_path` on the target host. You can then include the `filebeat_ca_path` within your configuration to properly authenticate your TLS connections to Logstash/Elasticsearch/etc.
 
  If you wish to load your CA certificate from a file, use the `file` lookup plugin, e.g.:
  ``` yaml
  filebeat_ca_cert: "{{ lookup('file', '/path/to/ca.crt') }}"
  ```
 - `filebeat_ca_path` - If a CA certificate is provided in `filebeat_ca_cert`, it will be created at this path. 

Similar to the CA variables, you can upload SSL certificates and keys for filebeat using these variables:

 - `filebeat_ssl_cert` - Contents of the SSL certificate
 - `filebeat_ssl_cert_path` - Destination of the certificate on the Ansible controlled host
 - `filebeat_ssl_key` - Contents of the SSL key
 - `filebeat_ssl_key_path` - Destination of the SSL key on the Ansible controlled host

You can also store the config in separate `filebeat.yml` file and include it using [lookup](http://docs.ansible.com/ansible/playbooks_lookups.html#intro-to-lookups-getting-file-contents):

``` yaml
filebeat_config: "{{ lookup('file', './filebeat.yml')|from_yaml }}"
```

Common Configurations
---------------------

Connecting to Elasticsearch:

  ``` yaml
  filebeat_config:
    filebeat:
      prospectors:
        - paths:
            - /var/log/messages
            - /var/log/*.log
          input_type: log
    output:
      elasticsearch:
        hosts:
          - "http://localhost:9200"
        username: "bob"
        password: "12345"
    logging:
      to_syslog: true
      level: error
  ```

License
-------

BSD

Author Information
------------------

David Wittman
