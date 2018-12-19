#!/bin/bash

# Author: Harsha <harshavardhanc95@gmail.com>

# update the VM details in create_vm file

# checking for argumnent
if [[ $# == '0' ]]; then
    echo "Please provide the Input file path"
    echo "Usage: $0 <input_file_path>"
    exit 1
fi

# reading input file values
IFS=","
grep -v -e "^#" -e "^$" $1 | while read -ra LINE
do
    rg="${LINE[0]}"
    location="${LINE[1]}"
    vnet="${LINE[2]}"
    sn="${LINE[3]}"
    ap="${LINE[4]}"
    sp="${LINE[5]}"
    nsg="${LINE[6]}"
    aset="${LINE[7]}"
    vname="${LINE[8]}"
    size="${LINE[9]}"
    baseos="${LINE[10]}"
    uname="${LINE[11]}"
    pubip="${LINE[12]}"
    pubkey="${LINE[13]}"

echo -e "\e[1;32mVM DETAILS\e[0m"
echo -e "RESOURCE_GROUP=$rg\nLOCATION=$location\nVNET_NAME=$vnet\nSUBNET_NAME=$sn\nADDRESS_PREFIX=$ap\nSUBNET_PREFIX=$sp\nNSG=$nsg\nAVAIL_SET=$aset\nVM_NAME=$vname\nSIZE=$size\nOS=$baseos\nUSER=$uname\nPUBLIC_IP=$pubip\nPATH_TO_PUB_KEY=$pubkey"


# valdating resource group and create if not exists
erg=$(az group list -o table | awk -F " " '{print $1}' | awk 'NR>2' | grep -E "^$rg$")

if [[ $? == "0" ]]; then
    echo -e "Resource group with this name \e[1;31m$rg\e[0m already exists"
else
    echo -e "Creating the Resource group \e[1;32m$rg..\e[0m"
    az group create --name $rg --location $location
fi

# valdating virtual network and create if not exists
evnet=$(az network vnet list -o table | awk -F " " '{print $4}' | awk 'NR>2' | grep -E "^$vnet$")

if [[ $? == "0" ]]; then
    echo -e "Vnet with this name \e[1;31m$vnet\e[0m already exists"
else
    echo -e "Creating the Vnet \e[1;32m$vnet..\e[0m"
    az network vnet create --resource-group $rg --name $vnet --address-prefix $ap --subnet-name $sn --subnet-prefix $sp
fi


# valdating network security group and create if not exists
ensg=$(az network nsg list -g $rg -o table | awk -F " " '{print $2}' | awk 'NR>2' | grep -E "^$nsg$")

if [[ $? == "0" ]]; then
    echo -e "Security group with this name \e[1;31m$nsg\e[0m already exists"
else
    echo -e "Creating the Security group \e[1;32m$nsg..\e[0m"
    az network nsg create --name $nsg --resource-group $rg
    az network nsg rule create --resource-group $rg --nsg-name $nsg --name ssh --protocol tcp --priority 1000 --destination-port-range 22 --access allow
fi

# valdating availability set and create if not exists
easet=$(az vm availability-set list -g $aset -o table | awk -F " " '{print $2}' | awk 'NR>2' | grep -E "^$aset$")

if [[ $? == "0" ]]; then
    echo -e "Availability set with this name \e[1;31m$aset\e[0m already exists"
else
    echo -e "Creating the Avaiablity set \e[1;32m$aset..\e[0m"
    az vm availability-set create --resource-group $rg --name $aset
fi

# attaching public ip
if [[ "$pubip" = "Yes" || "$pubip" = "yes" ]]; then
    echo "Public IP will be assigned to the instance"
elif [[ "$pubip" = "No" || "$pubip" = "no" ]]; then
    echo "Public IP will not be assigned"
else
    echo "Wrong input! please enter 'Yes' for Yes or 'No' for No"
fi


# valdating vm and create if not exists
evname=$(az vm list -g $rg -o table | awk -F " " '{print $2}' | awk 'NR>2' | grep -E "^$vname$")

if [[ $? == "0" ]]; then
    echo -e "Virtual Machine with this name \e[1;31m$vname\e[0m already exists"
elif [[ "$pubip" == "Yes" || "$pubip" == "yes" ]]; then
    echo -e "Creating Your Virtual Machine \e[1;32m$vname\e[0m hold on.."
    az vm create --resource-group $rg --name $vname --location $location --availability-set $aset --image $baseos --admin-username $uname --vnet-name $vnet --subnet $sn --nsg $nsg --size $size --ssh-key-value $pubkey 
else
    echo -e "Creating Your Virtual Machine \e[1;32m$vname\e[0m hold on.."
    az vm create --resource-group $rg --name $vname --location $location --availability-set $aset --image $baseos --admin-username $uname --vnet-name $vnet --subnet $sn --nsg $nsg --size $size --public-ip-address "" --ssh-key-value $pubkey
fi

done
