#!/bin/sh
set -e
master_node_ip=$1
agent_nodes=$(ssh -o StrictHostKeyChecking=no -i /run/secrets/ops-private-key ops@$master_node_ip "docker node ls -f role=worker --format {{.Hostname}}")
for agent_node in $agent_nodes; do
    echo ""
    echo  "Cleaning node: $agent_node"
    eval `ssh-agent -s` && ssh-add /run/secrets/ops-private-key && ssh -A -o StrictHostKeyChecking=no ops@$master_node_ip "ssh -o StrictHostKeyChecking=no $agent_node 'docker container prune -f && docker image prune -f'"
done;