Prometheus node_exporter
========================

Ansible [Prometheus](https://prometheus.io) [node_exporter](https://github.com/prometheus/node_exporter) role

Requirements
------------

* Debian Jessie or newer

Role Variables
--------------

see `defaults/main.yml`

Example Playbook
----------------

    - hosts: all
      roles:
        - role: SphericalElephant.prometheus-node-exporter
          prometheus_node_exporter_file_sd: True
          prometheus_node_exporter_file_sd_locations:
            - { host: prometheus01.in.example.com, path: "/etc/prometheus/endpoints/node-{{ inventory_hostname }}.yml" }
           
License
-------

Apache 2.0
