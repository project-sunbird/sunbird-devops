// Importing deploy configuration
@Library('deploy-conf') _

// Defining env specific variables
def getValues() {
    if (environment == "dev") {
        return [label: 'bronze',
               env: 'dev']
    }
    else {
        return [label: 'silver',
               env: 'staging']
    }
}

// Getting env specific values
def valus = getValues()

//Deploying service
buildPlugin(branch: 'master',
            scmUrl: 'https://github.com/project-sunbird/sunbird-devops.git',
            artifactName: 'metadata.json',
            artifactLabel: values.label,
            env: values.env,
            serviceName: 'content-service',
            parentProject: 'New_Build/Sunbird_ContentService_Build',
            deployExtraArgs: 'deploy_content=True'
            )
