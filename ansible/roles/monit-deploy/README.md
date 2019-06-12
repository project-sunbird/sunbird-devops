Monit
=========

Install and configure monit and use to append configs for new apps

Role Variables
--------------

```
monit_config:
  neo_4j:
    *app_name: neo_4j
    # This is for jobs, which doesn't have any start script and starting with custom commands
    custom_start: command start args
    custom_stop: command to stop the program
    # if custom_start/stop is not defined, by default script path will be /etc/init.d/app_name 
    # You can override with following
    script_path: /path/to/script
    *pidfile: /var/run/neo.pid
    retry_count: 3
    timeout: 60
    # user will be 'root' if nothing is defined
    user: neo
    # Group will be 'root' by default else if 'user' if defined else overridden by
    group: neo
    
 * Mandatory
``` 

Example Playbook
----------------

```
vars_file:
  - group_vars/monit_dev.yml
vars:
  service_name: 
    - neo_4j
    - api-service
    - cassandra
roles
  - monit 
```

#### OR
 
```
ansible-playbook -i inventories/qa.yml monit_deploy_apps.yml \
--limit cassandra \
--extra-vars service_name=cassandra \
--extra-vars @group_vars/monit_dev.yml

```

#### monit_deploy_apps.yml

```
- hosts: all
  name: Installing and configuring monit
  roles:
    - monit_generic
```

License
-------

BSD

Author Information
------------------

Rajesh Rajendran <rajesh.r@optit.co>
