#!/bin/bash
config_file=$TRAVIS_BUILD_DIR/deploy/config
install_script=$TRAVIS_BUILD_DIR/travis-ci-scripts/install_sb.sh
release_to_build=$TRAVIS_BUILD_DIR/travis-ci-scripts/release_to_build
app_ip=$(awk '/dns_name:/{ if ($2 !~ /#.*/) {print $2}}' $config_file)
user_name=$(awk '/ssh_ansible_user:/{if ($2 !~ /#.*/) {print $2}}' $config_file)
printf "%s$private_key" > sunbird.pem
chmod 600 sunbird.pem
echo $release > $release_to_build
scp -i sunbird.pem -o StrictHostKeyChecking=no $config_file sunbird.pem $install_script $release_to_build $user_name@$app_ip:/tmp
ssh -i sunbird.pem -o StrictHostKeyChecking=no $user_name@$app_ip "/tmp/install_sb.sh"
if [[ $? -ne 0 ]]; then
   exit 1
fi
