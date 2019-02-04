#!/bin/bash
# Author S M Y <smy.altamash@gmail.com>
RGName=$1
KeyFileLocation=$2
vmnames=( $(az vm list-ip-addresses -o table -g $RGName | awk 'NR>2{print $1}' | tr "\n" " ")  )

if [ $# -ne 2 ];
then
	echo "Usage: bash rotateKey.sh ResourceGroupName KeyFileLocation"
fi

for name in "${vmnames[@]}"
do
	#Rotating SSH Pem Key
	echo "changing key for server $name my master"
	echo "------------------------------------------------------------------"
	az vm user update --name $name \
			  --resource-group $RGName \
			  --username ops \
			  --ssh-key-value "$(cat $KeyFileLocation)"
	echo "------------------------------------------------------------------"
done
