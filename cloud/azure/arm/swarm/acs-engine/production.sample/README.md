### Understanding deploy parameters
Below is a sample file with comments:
```
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "agentpublicCount": {
        // number of agents you want to launch
        // agent machines run your application services.
        // So, if you detect services not starting up or running slow
        // bump up the number of agents
        "value": 1
      },
      "agentpublicEndpointDNSNamePrefix": {
        // this is the DNS Name for your application servers
        "value": "production-1b"
      },
      "agentpublicSubnet": {
        // private subnet range for your agent machines
        "value": "10.1.0.0/16"
      },
      "internalLBprivateIPAddress": {
        "value": "10.1.0.100"
      },
      "agentpublicVMSize": {
        // the agent VM size
        // Note that you cannot change it once you have set it
        // Standard_F2s is a good 2 core 4 gig minimum machine to start with
        "value": "Standard_F2s"
      },
      "firstConsecutiveStaticIP": {
        "value": "172.16.1.5"
      },
      "linuxAdminUsername": {
        // the linux administrator user name
        // will be used to SSH
        "value": "ops"
      },
      "location": {
        // Any Azure location which servers your interest
        "value": "centralindia"
      },
      "masterEndpointDNSNamePrefix": {
        // DNS Name for master server
        // master server is used to administer application services
        "value": "production-1a"
      },
      "masterSubnet": {
        // master server subnet
        "value": "172.16.1.0/24"
      },
      "masterVMSize": {
        // This dependends on your work load.
        // Standard_F2s is a good starting configuration
        "value": "Standard_F2s"
      },
      "masterCount": {
        // Need an odd number of servers
        // 1 is a risky configuration with no fail over
        // Use 3 or more when you have passed testing phase
        "value": 1
      },
      "sshRSAPublicKey": {
        // Put in the RSA 2048 bit SSH Public key for SSH login
        // refer to linuxAdminUsername above
        "value": ""
      },
      "targetEnvironment": {
        "value": "AzurePublicCloud"
      },
      "nameSuffix":{
        // unique name to be prepended for Azure Resource Group name
        // Change it if you need to create a new setup
       "value": "" 
      }
      
    }
  }
```