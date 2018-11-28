// common plugin to clone code and build
def call(Map pipelineParams) {
def deployScript = libraryResource 'deploy.sh'
pipeline {
        agent { label "${pipelineParams.agent}" }
        environment{
            METADATA_FILE = "${pipelineParams.artifactName}"
            ARTIFACT_LABEL = "${pipelineParams.artifactLabel}"
            ENV = "${pipelineParams.env}"
            SERVICE_NAME = "${pipelineParams.serviceName}"
            DEPLOY_EXTRA_ARGS = "${pipelineParams.deployExtraArgs}"
        }
        stages {
            // cloning public sunbird-devops
            stage('checkout git') {
                steps {
                    // checkout scm
                    // This should be replaced with above step
                    git branch: 'release-1.12', url: 'https://github.com/ekstep/sunbird-devops', credentialsId: 'f37ad21f-744a-4817-9f5e-02f8ec620b39'
                    dir('sunbird-devops'){
                    git branch: pipelineParams.branch, url: pipelineParams.scmUrl
                    }
                }
            }

            stage('Deploy') {
                steps {
                    sh 'ls'
                    script{
                        step ([$class: 'CopyArtifact',
                        projectName: pipelineParams.parentProject,
                        filter: pipelineParams.artifactName]);
                    }
                    sh(deployScript)
                    archiveArtifacts 'metadata.json'
                }
            }
        }
    }
}
