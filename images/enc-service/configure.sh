mkdir /badger

# Installing all prerequisites
apk update
apk add git python build-base

# Cloning source code of badger
git clone https://github.com/project-sunbird/enc-service.git code
# Removing unwanted packages
apk del git build-base
rm -rf /var/cache/apk/*
