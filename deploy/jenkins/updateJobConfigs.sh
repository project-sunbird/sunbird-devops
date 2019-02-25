#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

echo -e "\e[0;36m${bold}
Updating jenkins jobs for other environments - Run this script from the folder you want to configure \
\n\nTo setup staging from dev \
\nOld text - ArtifactUpload/dev/ \
\nNew text - Deploy/dev/ \
	
\nTo setup pre-production from staging - Copy staging dir and rename it to pre-production \
\nOld text - Deploy/dev/ \
\nNew text - Deploy/staging/ \
	
\nTo setup production from pre-production - Copy pre-production dir and rename it to production \
\nOld text - Deploy/staging/ \
\nNew text - Deploy/pre-production/ \
\n${normal}"

read -p 'Old text: ' oldText
read -p 'New text: ' newText
find . -type f -name config.xml -exec sed -i "s#$oldText#$newText#g" {} \;
