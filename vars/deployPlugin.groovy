def call(Map pipelineParams) {
def deployScript = libraryResource 'deploy.sh'
pipeline {
        agent {
            node {
                label "${pipelineParams.agent}"
                env.METADATA_FILE = "${pipelineParams.artifactName}"
                env.ARTIFACT_LABEL = "${pipelineParams.artifactLabel}"
                env.ENV = "${pipelineParams.env}"
                env.SERVICE_NAME = "${pipelineParams.serviceName}"
                env.DEPLOY_EXTRA_ARGS = "${pipelineParams.deployExtraArgs}"
            }
        }
        stages {
           stage('checkout private repo') {
                    dir('sunbird-devops-private'){
                    sh 'pwd && ls -lrth'
                    println pipelineParams.branch
                    println        pipelineParams.scmUrl
                     println       pipelineParams.credentials
                    git branch: pipelineParams.branch, url: pipelineParams.scmUrl, credentialsId: pipelineParams.credentials
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
//                    sh deployScript
//                    archiveArtifacts 'metadata.json'
                      println pipelineParams
                }
            }
        }
    }
}
