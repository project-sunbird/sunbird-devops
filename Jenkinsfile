@Library('deploy-conf') _
def getValues() {
    if (environment == "dev") {
        return 'bronze'
    }
    else {
        return 'silver'
    }
}
buildPlugin(branch: 'master',
            scmUrl: 'https://github.com/project-sunbird/sunbird-devops.git',
            artifactName: 'metadata.json',
            artifactLabel: getValues(),
            env: 'dev',
            parentProject: 'New_Build/Sunbird_ContentService_Build'
            )
