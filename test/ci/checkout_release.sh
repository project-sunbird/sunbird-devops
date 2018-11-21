#!/bin/bash

if [[ $CIRCLE_JOB == "previous-stable" && $addon == "upgrade" ]]; then
    RELEASE=tags/$(git tag | grep "release-[0-9].*[0-9]$" | sort -V -r | awk -F "." '!($2 in a){i++; a[$2]} (i==1){print $0}' | head -1)
elif [[ $CIRCLE_JOB == "previous-stable" ]]; then
    RELEASE=tags/$(git tag | grep "release-[0-9].*[0-9]$" | sort -V -r | awk -F "." '!($2 in a){i++; a[$2]} (i==2){print $0}' | head -1)
elif [[ $CIRCLE_JOB == "current-stable" ]]; then
    RELEASE=tags/$(git tag | grep "release-[0-9].*[0-9]$" | sort -V -r | awk -F "." '!($2 in a){i++; a[$2]} (i==1){print $0}' | head -1)
elif [[ $CIRCLE_JOB == "current-dev-branch" ]]; then
    RELEASE=$(git branch -a | grep "release-[0-9].*[0-9]$" | sed 's#.*/.*/##g' |  tr -d ' ' | sort -V -r | awk -F "." '!($2 in a){i++; a[$2]} (i==1){print $0}' | head -1)
fi

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

release_to_build=./test/ci/release_to_build
echo $RELEASE > $release_to_build
echo $CIRCLE_BUILD_URL >> $release_to_build
