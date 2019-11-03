# vim: set ts=4 sw=4 tw=0 et :

#!/bin/bash
cluster_name=$1
service_principal=$2
client_secret=$3
ssh_public_key_location=$4
subscription_id=$5

az aks  create --resource-group test --name ${cluster_name} \
   --node-count 1 --admin-username deployer  --kubernetes-version 1.14.7 \
   --service-cidr 172.16.0.0/16 --service-principal ${service_principal} \
   --node-vm-size Standard_D4s_v3 --client-secret ${client_secret} \
   --network-plugin kubenet --dns-service-ip 172.16.10.10 \
   --ssh-key-value @${ssh_public_key_location}  -l centralindia \
   --vm-set-type VirtualMachineScaleSets \
   --vnet-subnet-id /subscriptions/${subscription_id}/resourceGroups/Test/providers/Microsoft.Network/virtualNetworks/Test-vnet/subnets/default
