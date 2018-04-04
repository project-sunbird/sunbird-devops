#!/bin/sh
cd /tmp

#Check cassandra migration jar file present or not inside /tmp
if [ -f cassandra-migration-0.0.1-SNAPSHOT-jar-with-dependencies.jar ] 
then
  rm -rf cassandra-migration-0.0.1-SNAPSHOT-jar-with-dependencies.jar
fi

wget https://github.com/project-sunbird/sunbird-utils/releases/download/R1.5/cassandra-migration-0.0.1-SNAPSHOT-jar-with-dependencies.jar

# Start the java process to apply cassandra migration 
nohup java -cp "cassandra-migration-0.0.1-SNAPSHOT-jar-with-dependencies.jar" com.contrastsecurity.cassandra.migration.utils.MigrationScriptEntryPoint &
