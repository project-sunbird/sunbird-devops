#!/bin/bash

cd $HOME

# If `docker run` first argument start with `-` the user is passing jenkins swarm launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "-"* ]]; then

  # Jenkins swarm slave
  #JAR=`ls -1 /usr/share/jenkins/swarm-client-*.jar | tail -n 1`
  JAR=/home/jenkins/swarm-client-${SWARM_CLIENT_VERSION}.jar
  PARAMS=""
  # if -master is not provided and using --link jenkins:jenkins
  if [[ "$@" != *"-master "* ]] && [ ! -z "$JENKINS_MASTER_PORT" ]; then
    PARAMS="$PARAMS -master http://$JENKINS_MASTER_HOST:$JENKINS_MASTER_PORT/jenkins"
  fi
  CMD="java $JAVA_OPTS -jar $JAR -fsroot $HOME -username `cat $JENKINS_SLAVE_USERNAME` -password `cat $JENKINS_SLAVE_PASSWORD` -mode $JENKINS_SLAVE_MODE -name $JENKINS_SLAVE_NAME -executors $JENKINS_SLAVE_EXECUTORS $PARAMS $@"
  echo Running $CMD
  exec $CMD
fi

# Argument passed was not jenkins, so we assume the user wants to run their own process
exec "$@"
