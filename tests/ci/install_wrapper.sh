#!/bin/bash

copyPem(){
   mkdir /home/$username/.ssh 2> /dev/null
   cp /tmp/sunbird.pem /home/$username/.ssh
}

checkoutRepo(){
   cd /home/$username
   sudo rm -rf sunbird-devops
   git clone https://github.com/project-sunbird/sunbird-devops.git
   cd sunbird-devops
   getTags
   if [[ $index != "" ]]; then
      git checkout tags/$release -b $release
      echo -e "Installing sunbird on tags $release" | tee $wrapper_log
   else
      git checkout -b $release origin/$release
      echo -e "Installing sunbird on branch $release" | tee -a $wrappper_log
   fi
   cd deploy
}

updateConfig(){
   if [[ -f config ]]; then
      config_file=config
   else
      config_file=config.yml
   fi

   keys=$(awk '{print $1}' $build_info)
   for j in ${keys[@]}
   do
      value=$(awk '/'^$j'/{ if ($2 !~ /#.*/) {print $2}}' $build_info)
      sed -i "s|^$j.*#|$j $value                    #|g" $config_file
   done
}

getTags(){
   declare -A arr
   i=1
   while true
   do
      tag=$(git tag | grep "release-[0-9].*[0-9]$" | sort -V -r | awk -F "." '!($2 in a){i++; a[$2]} (i=='$i'){print $0}' | head -1)
      if [[ $tag != "" ]]; then
         arr[$tag]=$i
         i=$(expr $i + 1)
      else
         break
      fi
   done
   index=${arr["$release"]}
}

checkForUpgrade(){
   if [[ $index -gt 1 ]]; then
      i=$(($index - 1))
      previous=$release
      release=$(git tag | grep "release-[0-9].*[0-9]$" | sort -V -r | awk -F "." '!($2 in a){i++; a[$2]} (i=='$i'){print $0}' | head -1)
      echo "Not latest release. Upgrading from $previous to $release..." | tee -a $wrappper_log
   else
      echo "Latest release, ignoring upgrade..." | tee -a $wrappper_log
      archiveLogs
      sendEmail
      exit 0
   fi
}

upgradeSB(){
   version=$(echo $release | awk -F "-" '{print $2}' | awk -F "." '{print $1"."$2}')
   checkoutRepo
   updateConfig
   bash /tmp/tests/ci/upgrade_sunbird-$version.sh $config_file $release $build_info $version $previous
   if [[ $? -ne 0 ]]; then
      postResult
   else
      archiveLogs
      sendEmail
   fi
}

installSB(){
   bash /tmp/tests/ci/install_sunbird-$version.sh $config_file $release $build_info
   if [[ $? -ne 0 ]]; then
      postResult
   else
      checkForUpgrade
      upgradeSB
   fi
}

archiveLogs(){
   sudo apt install -y zip
   mkdir logs 2> /dev/null
   cp $wrapper_log logs
   zip -r /tmp/serverlogs.zip logs
}

sendEmail(){
   python /tmp/tests/ci/send_email.py
}

postResult(){
   archiveLogs
   sendEmail
   exit 1
}

build_info=/tmp/tests/ci/build_info
email_file=/tmp/tests/ci/send_mail.py
release=$(awk '/release:/{ if ($2 !~ /#.*/) {print $2}}' $build_info)
username=$(awk '/ssh_ansible_user:/{ if ($2 !~ /#.*/) {print $2}}' $build_info)
release=$(awk '/release:/{ if ($2 !~ /#.*/) {print $2}}' $build_info)
version=$(echo $release | awk -F "-" '{print $2}' | awk -F "." '{print $1"."$2}')
wrapper_log=/tmp/wrapperlog.txt

copyPem
checkoutRepo
updateConfig
installSB
