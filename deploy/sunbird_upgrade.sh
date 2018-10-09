#!/bin/sh
implementation_name=$(awk '/implementation_name: /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
env_name=$(awk '/env: /{ if ($2 !~ /#.*/) {print $2}}' config.yml)
ansible_variable_path="${implementation_name}"-devops/ansible/inventories/"$env_name"
ansible-playbook -i $ansible_variable_path/hosts ../ansible/system-init-upgrade.yml --extra-vars @config.yml

export sunbird_cassandra_host=`ip route get 8.8.8.8 | awk '{print $NF; exit}'`
export sunbird_cassandra_port=9042

cd /tmp

#Check cassandra migration jar file present or not inside /tmp
if [ -f cassandra-migration-0.0.1-SNAPSHOT-jar-with-dependencies.jar ] 
then
  rm -rf cassandra-migration-0.0.1-SNAPSHOT-jar-with-dependencies.jar
fi

wget https://github.com/project-sunbird/sunbird-utils/releases/download/R1.5/cassandra-migration-0.0.1-SNAPSHOT-jar-with-dependencies.jar

# Start the java process to apply cassandra migration 
nohup java -cp "cassandra-migration-0.0.1-SNAPSHOT-jar-with-dependencies.jar" com.contrastsecurity.cassandra.migration.utils.MigrationScriptEntryPoint &

