#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)
today=$(date +%Y-%m-%d-%H-%M-%S)
JENKINS_TMP=/tmp/$today
envOrder="/dev/null"

setupJobs(){
  declare -A arr
  while IFS="" read -r line; do
     key=$(echo $line | awk -F "=" '{print $1}')
     value=$(echo $line | awk -F "=" '{print $2}')
     arr[$value]=$key
   done < $envOrder
   mkdir $JENKINS_TMP
   rsync -r jobs/* $JENKINS_TMP
   if [[ ${arr[0]} != "dev" ]]; then
      mv $JENKINS_TMP/ArtifactUpload/jobs/dev $JENKINS_TMP/ArtifactUpload/jobs/${arr[0]}
      mv $JENKINS_TMP/Deploy/jobs/dev $JENKINS_TMP/Deploy/jobs/${arr[0]}
      mv $JENKINS_TMP/OpsAdministration/jobs/dev $JENKINS_TMP/OpsAdministration/jobs/${arr[0]}
      mv $JENKINS_TMP/Provision/jobs/dev $JENKINS_TMP/Provision/jobs/${arr[0]}
      find $JENKINS_TMP/Deploy/jobs/${arr[0]} -type f -name config.xml -exec sed -i "s#ArtifactUpload/dev/#ArtifactUpload/${arr[0]}/#g" {} \;
      find $JENKINS_TMP/Deploy/jobs/${arr[0]} -type f -name config.xml -exec sed -i "s#Deploy/dev/#Deploy/${arr[0]}/#g" {} \;
   fi
   find $JENKINS_TMP/Deploy/jobs/${arr[0]} -type d -path "*Summary*" -prune -o -name config.xml -exec sed -i 's#<upstreamProjects>.*##g' {} \;
   find $JENKINS_TMP/Build/jobs -type f -name config.xml -exec sed -i 's#refs/heads/${public_repo_branch}##g' {} \;
   find $JENKINS_TMP/Build/jobs -type f -name config.xml -exec sed -i 's#use refs/tags/github_tag#specify the github tag#g' {} \;
   find $JENKINS_TMP/Build/jobs -type f -name config.xml -exec sed -i 's#use refs/heads/github_branch#specify the github branch#g' {} \;
   find $JENKINS_TMP/Build/jobs -type f -name config.xml -exec sed -i '/The default value of/d' {} \;
   find $JENKINS_TMP/Build/jobs -type f -name config.xml -exec sed -i '/To build from a differnt branch/d' {} \;

   echo -e "\e[0;33m${bold}Jobs created for ${arr[0]}${normal}"

   for key in "${!arr[@]}"; do
      if [[ $key -eq 0 ]]; then
         continue
      fi
      cp -r $JENKINS_TMP/Provision/jobs/${arr[0]} $JENKINS_TMP/Provision/jobs/${arr[$key]}
      cp -r $JENKINS_TMP/OpsAdministration/jobs/${arr[0]} $JENKINS_TMP/OpsAdministration/jobs/${arr[$key]}
      cp -r $JENKINS_TMP/Deploy/jobs/${arr[0]} $JENKINS_TMP/Deploy/jobs/${arr[$key]}
      find $JENKINS_TMP/Deploy/jobs/${arr[$key]} -type f -name config.xml -exec bash -c 'configPath=$0; jobPath=$(dirname $configPath); jobName=$(basename $jobPath); modulePath=${jobPath%/*/*}; moduleName=$(basename $modulePath); sed -i "s#ArtifactUpload/$1/$moduleName/.*<#Deploy/$2/$moduleName/$jobName<#g" $0' {} ${arr[0]} ${arr[$(($key - 1))]} \;
      find $JENKINS_TMP/Deploy/jobs/${arr[$key]} -type d -path "*Summary*" -prune -o -name config.xml -exec sed -i 's#<upstreamProjects>.*##g' {} \;
      find $JENKINS_TMP/Deploy/jobs/${arr[$key]}/jobs/Summary/jobs/DeployedVersions -type f -name config.xml -exec sed -i "s#Deploy/${arr[0]}/#Deploy/${arr[$key]}/#g" {} \;
      echo -e "\e[0;33m${bold}Jobs created for ${arr[$key]}${normal}"
   done
   echo -e "\e[0;36m${bold}Do you want to disable auto trigger of build jobs based on new commits?${normal}"
   read -p 'y/n: ' choice
   if [[ $choice == "y" ]]; then
      find $JENKINS_TMP/Build -type f -name config.xml -exec sed -i 's#<spec>.*</spec>#<spec></spec>#g' {} \;
      find $JENKINS_TMP/Deploy -type f -name config.xml -exec sed -i 's#<spec>.*</spec>#<spec></spec>#g' {} \;
   fi
   echo -e "\e[0;36m${bold}Do you want to disable daily backup jobs (Ex: DB backups)?${normal}"
   read -p 'y/n: ' choice
   if [[ $choice == "y" ]]; then
      find $JENKINS_TMP/OpsAdministration -type f -name config.xml -exec sed -i 's#<spec>.*</spec>#<spec></spec>#g' {} \;
   fi
   find $JENKINS_TMP/Build -type f -name config.xml -exec sed -i 's#<upstreamProjects>.*##g' {} \;
   find $JENKINS_TMP -type f -name config.xml -exec sed -i 's#<sandbox>false</sandbox>#<sandbox>true</sandbox>#g' {} \;
   diffs=$(colordiff -r --suppress-common-lines --no-dereference -x 'nextBuildNumber' -x 'builds' -x 'last*' /var/lib/jenkins/jobs $JENKINS_TMP | wc -l)
   if [[ $diffs -eq 0 ]]; then
      echo -e "\e[0;33m${bold}No changes detected. Exiting...${normal}"
      exit
   fi
   colordiff -r --suppress-common-lines --no-dereference -x 'nextBuildNumber' -x 'builds' -x 'last*' --suppress-blank-empty --ignore-tab-expansion --ignore-trailing-space --ignore-space-change  --ignore-matching-lines='<com.cloudbees' --ignore-matching-lines='<org.jenkinsci' --ignore-matching-lines='<registry plugin' --ignore-matching-lines='<flow-definition' --ignore-matching-lines='<com.sonyericsson' --ignore-matching-lines='<org.biouno' --ignore-matching-lines='<secureScript' --ignore-matching-lines='<secureFallbackScript' --ignore-matching-lines='<hudson.plugins' --ignore-matching-lines='<definition class' --ignore-matching-lines='<scm class' --ignore-matching-lines='</flow' --ignore-matching-lines='<configVersion>'  --ignore-matching-lines='<visibleItemCount>' --ignore-matching-lines='<parameters class' /var/lib/jenkins/jobs $JENKINS_TMP
   echo -e "\e[0;33m${bold}Please review the changes shown. Proceed with overwriting the changes?${normal}"
}

syncJobs(){
read -p 'YES/NO: ' changes
echo -e "\e[0;33m${bold}This might take a while... Do not kill the process!${normal}"
   if [[ $changes == "YES" ]]; then
     rsync -r $JENKINS_TMP/* /var/lib/jenkins/jobs
     chown -R jenkins:jenkins /var/lib/jenkins/jobs
     echo -e "\e[0;32m${bold}Setup complete!${normal}"
   else
        echo -e "\e[0;31m${bold}Aborted!${normal}"
   fi
}


firstRun(){
choice="n"
envOrder=envOrder.txt
cat $envOrder
echo -e "\e[0;36m${bold}Is this the correct order? Jobs will be created and configured based on this order.${normal}"
read -p 'y/n: ' choice
if [[ $choice == "y" ]]; then
   setupJobs
   syncJobs
   cp $envOrder /var/lib/jenkins
   chown -R jenkins:jenkins /var/lib/jenkins/$envOrder
else
   echo -e "\e[0;31m${bold}Please update the envOrder.txt and re-run..${normal}"
fi
}

updateRun(){
choice="n"
envOrder=/var/lib/jenkins/envOrder.txt 
cat $envOrder
echo -e "\e[0;36m${bold}Is this the current order? Choose n if you want to add a new environment.${normal}"
read -p 'y/n: ' choice
if [[ $choice == "n" ]]; then
   rm -rf $envOrder
   echo -e "\e[0;31m${bold}Please update the envOrder.txt and re-run from sunbird-devops/deploy/jenkins directory."
elif [[ $choice == "y" ]]; then
   setupJobs
   syncJobs
else
   echo -e "\e[0;31m${bold}Aborted!${normal}"   
fi
}

echo -e "\e[0;33m${bold}**** Welcome to Jenkins config setup! ****${normal}"
if [[ ! -f /var/lib/jenkins/envOrder.txt ]]; then
   if [[ ! -f ./envOrder.txt ]]; then
      echo -e "\e[0;31m${bold}Please create a file named envOrder.txt with your environment order. Refer envOrder.txt.sample for reference"
   else
      echo -e "\e[0;33m${bold}Starting setup...${normal}"
      firstRun
   fi
else
   echo -e "\e[0;33m${bold}Checking for updates...${normal}"
   updateRun
fi
