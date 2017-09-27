### Pre-requisites

You will need servers with the following minimum system requirements:
- Operating System: Ubuntu 16.04 LTS
- RAM: 4GB
- CPU: 2 core, >2 GHz
- root access (should be able to sudo)

### Variables relevant to deployment
- **implementation-name** - Name of the sunbird deployment. This could be anything. Let's say for the sake of this document, it is `flamingo`
- **environment-name** - Name of the environment you are deploying. Typically, it is one of development, test, staging, production, etc. For this document, lets say we are setting up a `test` environment.

### Step 1: Provisioning your application servers
#### Automated
##### Azure
The following set of scripts create the network and servers needed to run Sunbird on Azure. On any machine, e.g. your laptop run:
- Clone the sunbird-devops repo using `git clone https://github.com/project-sunbird/sunbird-devops.git`
- Run `./sunbird-devops/deploy/generate-config.sh flamingo test cloud` This will create config files for you in `./flamingo-devops/test/azure`
- Edit BOTH files `azuredeploy.parameters.json` and `env.sh`. 
- Run `export DEPLOYMENT_JSON_PATH=<absolute path of azuredeploy.parameters.json>`. For instance, on my laptop it is `export DEPLOYMENT_JSON_PATH=/Users/shashankt/code2/sunbird/flamingo-devops/test/azure/`
- Run `cd sunbird-devops/deploy`
- [10 mins] Run `./provision-servers.sh`
- Login to Azure when CLI instructs
- Wait for deployment to complete
- Check on Azure portal: Resource Group -> Deployments -> Click on deployment to see deployment details. 
- Try to SSH. If your `masterFQDN` from deployment details was `test-1a.centralindia.cloudapp.azure.com` you can ssh using `ssh -A ops@test-1a.centralindia.cloudapp.azure.com`
- If you could SSH, you have successfully created the server platform.

##### Others
Not automated as of now but you are free to contribute back!
#### Manual
Get 2 servers and prepare to get your hands dirty when needed.

### Step 2: Setup
We will be setting up the `db-server` first and then configure and setup the `application-server`.

#### db-server setup
- SSH into the `db-server`.
- Clone the sunbird-devops repo using `git clone https://github.com/project-sunbird/sunbird-devops.git`
- We need to generate configuration(from sample config) for the environment before starting deployment
- Run `./sunbird-devops/deploy/generate-config.sh <implementation-name> <environment-name>`. Example `./sunbird-devops/deploy/generate-config.sh ntp staging`. This creates `<implementation-name>-devops` directory with sample configurations using [ansible directory structure](http://docs.ansible.com/ansible/latest/playbooks_best_practices.html#alternative-directory-layout)
- [5 mins] Modify all the configurations under `# DB CONFIGURATION` block in `<implementation-name>-devops/ansible/inventories/<environment-name>/group_vars/<environment-name>`
- Run `cd sunbird-devops/deploy`
- [15 mins] Run `sudo ./install-dbs.sh <implementation-name>-devops/ansible/inventories/<environment-name>`. This script takes roughly 10-15 mins (in an environment with fast internet) and will install the databases.
- [1 min] Run `sudo ./init-dbs.sh <implementation-name>-devops/ansible/inventories/<environment-name>` to initialize the DB.

#### application-server setup
- SSH into `application-server`.
- Clone the sunbird-devops repo using `git clone https://github.com/project-sunbird/sunbird-devops.git`
- Copy over the configuration directory (`<implementation-name>-devops`) to this machine
- [5 mins] Modify all the configurations under `# APPLICATION CONFIGURATION` block
- Sunbird proxy service will require SSL certificates. Details of the certificates have to added in the configuration, please see [this wiki](https://github.com/project-sunbird/sunbird-commons/wiki/Updating-SSL-certificates-in-Sunbird-Proxy-service) for details on how to do this. Note: If you don't have SSL certificates and want to get started you could generate and use [self-signed certificates](https://en.wikipedia.org/wiki/Self-signed_certificate), steps for this are detailed in [this wiki](https://github.com/project-sunbird/sunbird-commons/wiki/Generating-a-self-signed-certificate)
- Run `cd sunbird-devops/deploy`
- Run `sudo ./install-deps.sh`. This will install dependencies.
- Run `sudo ./deploy-apis.sh <implementation-name>-devops/ansible/inventories/<environment-name>`. This will onboard various APIs and consumer groups.

**Note:** Next 2 steps are necessary only when the application is being deployed for the first time and could be skipped for subsequent deploys.

- deploy-apis.sh script will print a JWT token that needs to be updated in the application configuration. To find the token search the script output to look for "JWT token for player is :", copy the corresponding token. Example output below, token is highlighted in italics:

  > changed: [localhost] => {"changed": true, "cmd": "python /tmp/kong-api-scripts/kong_consumers.py 
  /tmp/kong_consumers.json ....... "**JWT token for player is :**
  *eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJlMzU3YWZlOTRmMjA0YjQxODZjNzNmYzQyMTZmZDExZSJ9.L1nIxwur1a6xVmoJZT7Yc0Ywzlo4v-pBVmrdWhJaZro*", "Updating rate_limit for consumer player for API cr......"]}

- Update `sunbird_api_auth_token` in you configuration with the above copied token. 
- Run `sudo ./deploy-core.sh <implementation-name>-devops/ansible/inventories/<environment-name>`. This will setup all the sunbird core services. 
- Run `sudo ./deploy-proxy.sh <implementation-name>-devops/ansible/inventories/<environment-name>`. This will setup sunbird proxy services. 

### Instructions for testing the simple setup
[WIP] Rayulu, can you put in some steps to check if the installation is working. This is more like a functional check (this is not a smoke test, I know the smoke tests)

### Instructions for updating/redeploying the simple setup

### Instructions for updating logo/assets/resource bundles/etc
