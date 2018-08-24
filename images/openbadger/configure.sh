mkdir /badger

# Installing all prerequisites
apt-get update && apt-get install -y \
	git python-pip python-dev build-essential \
    nodejs npm libffi-dev libxml2-dev libxslt-dev \
    postgresql-client

pip install psycopg2

# Cloning source code of badger
cd /badger
git clone https://github.com/concentricsky/badgr-server.git code
cd code
git checkout -b sunbird e6b8568798686217d1b9fff06dde57e0a681dd25

# Mysql is not needed, but uses postgres
sed -i s/MySQL-python==1.2.5/#\ MySQL-python==1.2.5/ requirements.txt

# Installing all packages
pip install -r requirements-dev.txt
npm install

# Removing unwanted packages
#apk del build-base libffi-dev libxml2-dev libxslt-dev
# rm -rf /var/cache/apk/*
