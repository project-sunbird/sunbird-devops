#!/bin/sh

# This script won't work for aws, as it's black listed

echo -e "This script won't work for aws, as it's black listed\n so if youre running on aws please press ctrl+c"

sleep 5

echo please enter your dns name
read dns_name
ssh_ansible_user=$(whoami)
certbot_home=/etc/letsencrypt/archive/$dns_name


#Check certbot installed or not 
dpkg -S  `which certbot`
if [ $? -eq 0 ]
then
    echo "certbot is already installed"
else 
    sudo apt-get update
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository ppa:certbot/certbot
    sudo apt-get update
    sudo apt-get install -y certbot 	
fi

sudo ls $certbot_home
if [ $? -eq 0 ]
then
    echo "Certs are already created"
else
	sudo certbot certonly --standalone -d $dns_name 
fi
sudo cp -r $certbot_home/cert1.pem $certbot_home/privkey1.pem /home/$ssh_ansible_user/
sudo chown -R $ssh_ansible_user:$ssh_ansible_user /home/$ssh_ansible_user/cert1.pem /home/$ssh_ansible_user/privkey1.pem
sudo chmod 775 /home/$ssh_ansible_user/cert1.pem /home/$ssh_ansible_user/privkey1.pem
