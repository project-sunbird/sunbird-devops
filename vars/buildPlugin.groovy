// common plugin to clone code and build
def call(Map pipelineParams) {
def deployScript = libraryResource 'deploy.sh'
pipeline {
        agent pipelineParams.agent
        environment{
            METADATA_FILE = "${pipelineParams.artifactName}"
            ARTIFACT_LABEL = "${pipelineParams.artifactLabel}"
            ENV = "${pipelineParams.env}"
            SERVICE_NAME = "${pipelineParams.serviceName"}
            DEPLOY_EXTRA_ARGS = "${pipelineParams.deployExtraArgs}"
        }
        stages {
            stage('checkout git') {
                steps {
                    git branch: pipelineParams.branch, url: pipelineParams.scmUrl
                }
            }

            stage('Deploy') {
                steps {
                    sh 'ls'
                    copyArtifacts(
                    projectName: pipelineParams.parentProject,
                    filter: pipelineParams.artifactName
                    );
                    sh(deployScript)
                    archiveArtifacts 'metadata.json'
                }
            }
        }
    }
}
