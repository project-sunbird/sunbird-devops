@Library('deploy-conf') _
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
def valus = getValues()
buildPlugin(branch: 'master',
            scmUrl: 'https://github.com/project-sunbird/sunbird-devops.git',
            artifactName: 'metadata.json',
            artifactLabel: values.label,
            env: values.env,
            parentProject: 'New_Build/Sunbird_ContentService_Build'
            )
