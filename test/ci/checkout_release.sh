#!/bin/bash
cp -r test .circleci ./deploy/config.yml.sample /tmp
IFS="/" read -r var1 var2 <<< $RELEASE
if [[ $var1 == "tags" ]]; then
   git checkout $release -b $var2 --force
   echo -e "Checkout $var2"
else
   git checkout -b $var1 origin/$var1 --force
   echo -e "Checkout $var1"
fi

if ! [[ -f ./deploy/config.yml.sample ]]; then
   cp /tmp/config.yml.sample ./deploy
fi

cp -r /tmp/test /tmp/.circleci .

