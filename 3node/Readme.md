This is the test installation for sunbird in the most minimistic way.
Goals:
1. Ease of installation
2. Not for PRODUCTION


Tech Stack
1. Kuberentes

Tools
1. Local storage:
    `kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml`
    
    
Naming conventions:
All svc should end with `<deployment-name>-service` for example `player-service`
All Deployments should have `<application name>` for example `player`
