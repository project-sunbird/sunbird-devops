#!/bin/sh
master_node_ip=$1
agent_nodes=$(ssh -i /run/secrets/ops-private-key ops@$master_node_ip "docker node ls -f role=worker --format {{.Hostname}}")
for agent_node in $agent_nodes; do
    echo ""
    echo  "Cleaning node: $agent_node"
    eval `ssh-agent -s` && ssh-add /run/secrets/ops-private-key && ssh -A  ops@$master_node_ip "ssh $agent_node 'docker container prune -f && docker image prune -f'"
done;