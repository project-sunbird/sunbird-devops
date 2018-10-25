#!/bin/bash
config_file=./deploy/config.yml.sample
install_script=./test/ci/install_sb.sh
release_to_build=./test/ci/release_to_build
app_ip=$(awk '/dns_name:/{ if ($2 !~ /#.*/) {print $2}}' $config_file)
user_name=$(awk '/ssh_ansible_user:/{if ($2 !~ /#.*/) {print $2}}' $config_file)
printf "%s$private_key" > sunbird.pem
chmod 600 sunbird.pem
echo $RELEASE > $release_to_build
scp -i sunbird.pem -o StrictHostKeyChecking=no $config_file sunbird.pem $install_script $release_to_build $user_name@$app_ip:/tmp
ssh -i sunbird.pem -o StrictHostKeyChecking=no $user_name@$app_ip "/tmp/install_sb.sh"
if [[ $? -ne 0 ]]; then
   echo -e "\nSunbird installation for $RELEASE failed - Please inspect the server - Instance not removed!"
   exit 1
fi
