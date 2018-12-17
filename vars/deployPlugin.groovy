def call(Map pipelineParams) {
def deployScript = libraryResource 'deploy.sh'
        
 node(pipelineParams.agent){             
                env.METADATA_FILE = pipelineParams.artifactName
                env.ARTIFACT_LABEL = pipelineParams.artifactLabel
                env.ENV = pipelineParams.env
                env.SERVICE_NAME = pipelineParams.serviceName
                env.DEPLOY_EXTRA_ARGS = pipelineParams.deployExtraArgs
        
         stage('checkout private repo') {
            dir('sunbird-devops-private'){
            git branch: pipelineParams.branch, url: pipelineParams.scmUrl, credentialsId: pipelineParams.credentials
            }
        }
            stage('Deploy') {
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
