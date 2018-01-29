#!/bin/sh

DNS_NAME=$(awk '/dns_name: / {print $2}' config)
SSH_ANSIBLE_USER=$(awk '/ssh_ansible_user: / {print $2}' config)
CERTBOT_HOME=/etc/letsencrypt/archive/$DNS_NAME


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

sudo ls $CERTBOT_HOME
if [ $? -eq 0 ]
then
    echo "Certs are already created"
else
	sudo certbot certonly --standalone -d $DNS_NAME 
fi
sudo cp -r $CERTBOT_HOME/cert1.pem $CERTBOT_HOME/privkey1.pem /home/$SSH_ANSIBLE_USER/
sudo chown -R $SSH_ANSIBLE_USER:$SSH_ANSIBLE_USER /home/$SSH_ANSIBLE_USER/cert1.pem /home/$SSH_ANSIBLE_USER/privkey1.pem
sudo chmod 775 /home/$SSH_ANSIBLE_USER/cert1.pem /home/$SSH_ANSIBLE_USER/privkey1.pem