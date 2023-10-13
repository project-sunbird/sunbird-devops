#!/bin/bash

AccountName=$(grep "cloud_public_storage_accountname" global-values.yaml | awk -F ":" '{if($1=="cloud_public_storage_accountname") print $2}' | awk '{print $1}' | sed 's/^.\(.*\).$/\1/')

AccountKey=$(grep "cloud_public_storage_secret" global-values.yaml | awk -F ":" '{if($1=="cloud_public_storage_secret") print $2}' | awk '{print $1}' | sed 's/^.\(.*\).$/\1/')

#echo "Storage account name: $AccountName  AccountKey: $AccountKey"

# Content-plugins
rm -rf content-plugins
wget https://sunbirdartifact.blob.core.windows.net/artifacts/content-plugins.zip -O content-plugins.zip 
unzip content-plugins.zip -d content-plugins >> /dev/null 
unzip content-plugins/content-plugins.zip >> /dev/null
az storage blob upload-batch -d sunbird-contents-dev/content-plugins --account-name $AccountName --account-key $AccountKey -s content-plugins --overwrite true

# Content-editors
rm -rf content-editor
wget https://sunbirdartifact.blob.core.windows.net/artifacts/content-editor.zip -O content-editor.zip 
unzip content-editor.zip -d content-editor
unzip content-editor/content-editor.zip -d content-editor >> /dev/null
az storage blob upload-batch -d sunbird-contents-dev/content-editor --account-name $AccountName --account-key $AccountKey -s content-editor --overwrite true

# Collection editor
rm -rf collection-editor
wget https://sunbirdartifact.blob.core.windows.net/artifacts/collection-editor.zip -O collection-editor.zip 
unzip collection-editor.zip -d collection-editor
unzip collection-editor/collection-editor.zip -d collection-editor >> /dev/null
az storage blob upload-batch -d sunbird-contents-dev/collection-editor --account-name $AccountName --account-key $AccountKey -s collection-editor --overwrite true

# Preview
wget https://sunbirdartifact.blob.core.windows.net/artifacts/CR_Preview_Artifacts.zip:release-5.1.0_RC2 -O CR_Preview_Artifacts.zip
unzip CR_Preview_Artifacts.zip -d preview
unzip preview/preview.zip -d preview >> /dev/null 
az storage blob upload-batch -d sunbird-contents-dev/v3/preview --account-name $AccountName --account-key $AccountKey -s preview --overwrite true

#Generic Editor
rm -rf generic-editor
wget https://sunbirdartifact.blob.core.windows.net/artifacts/generic-editor.zip -O generic-editor.zip 
unzip generic-editor.zip -d generic-editor
unzip generic-editor/generic-editor.zip -d generic-editor >> /dev/null
az storage blob upload-batch -d sunbird-contents-dev/generic-editor --account-name $AccountName --account-key $AccountKey -s generic-editor --overwrite true



