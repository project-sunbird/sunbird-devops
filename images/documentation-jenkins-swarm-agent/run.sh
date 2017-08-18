if [ -f "${USER_NAME_SECRET}" ]; then
    read USR < ${USER_NAME_SECRET}
    COMMAND_OPTIONS="${COMMAND_OPTIONS} -username $USR"
fi

if [ -f "${PASSWORD_SECRET}" ]; then
    read PSS < ${PASSWORD_SECRET}
    COMMAND_OPTIONS="${COMMAND_OPTIONS} -password $PSS"
fi

java -jar /home/jenkins/swarm-client-${SWARM_CLIENT_VERSION}.jar ${COMMAND_OPTIONS}
