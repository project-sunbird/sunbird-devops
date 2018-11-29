#!/bin/bash
build_info=./tests/ci/build_info
app_ip=$(awk '/dns_name:/{ if ($2 !~ /#.*/) {print $2}}' $build_info)
user_name=$(awk '/ssh_ansible_user:/{if ($2 !~ /#.*/) {print $2}}' $build_info)
echo "release: $release" >> $build_info
if [[ $TRAVIS_BUILD_WEB_URL != "" ]]; then
   echo "build_url: $TRAVIS_BUILD_WEB_URL" >> $build_info
elif [[ $CIRCLE_BUILD_URL != "" ]]; then
   echo "build_url: $CIRCLE_BUILD_URL" >> $build_info
fi
printf "%s$private_key" > sunbird.pem
chmod 600 sunbird.pem
scp -i sunbird.pem -o StrictHostKeyChecking=no -r tests sunbird.pem $user_name@$app_ip:/tmp
ssh -i sunbird.pem -o StrictHostKeyChecking=no $user_name@$app_ip "/tmp/tests/ci/install_wrapper.sh"

if [[ $? -ne 0 ]]; then
   echo -e "\nSunbird installation for $release failed - Please inspect the server - Instance not removed!"
   exit 1
fi
