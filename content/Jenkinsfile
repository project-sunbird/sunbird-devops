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
values = getValues()

//Deploying service
buildPlugin(agent: 'general-dev',
            branch: gitBranch,
            scmUrl: 'https://github.com/project-sunbird/sunbird-devops.git',
            artifactName: 'metadata.json',
            artifactLabel: values.label,
            env: values.env,
            serviceName: 'content-service',
            parentProject: 'New_Build/Sunbird_ContentService_Build',
            deployExtraArgs: 'deploy_content=True'
            )
