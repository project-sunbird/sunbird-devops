mkdir /badger

# Installing all prerequisites
apk update
apk add git python-dev py-pip \
    nodejs-npm build-base libffi-dev libxml2-dev libxslt-dev \
    postgresql-dev
pip install  psycopg2

# Cloning source code of badger
cd /badger
git clone https://github.com/concentricsky/badgr-server.git code
cd code

# Mysql is not needed, but uses postgres
sed -i s/MySQL-python==1.2.5/#\ MySQL-python==1.2.5/ requirements.txt

# Installing all packages
pip install -r requirements-dev.txt
npm install

# Removing unwanted packages
apk del build-base libffi-dev libxml2-dev libxslt-dev
rm -rf /var/cache/apk/*
