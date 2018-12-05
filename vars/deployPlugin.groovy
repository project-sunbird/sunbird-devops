def call(body) {

    def deployScript = libraryResource 'deploy.sh'
    def pipelineParams = [:]
    body.resolveStrategy = Closure.DELEGATE_FIRST
    body.delegate = pipelineParams
    body()

    node(pipelineParams.agent){
            env.METADATA_FILE = "${pipelineParams.artifactName}"
            env.ARTIFACT_LABEL = "${pipelineParams.artifactLabel}"
            env.ENV = "${pipelineParams.env}"
            env.SERVICE_NAME = "${pipelineParams.serviceName}"
            env.DEPLOY_EXTRA_ARGS = "${pipelineParams.deployExtraArgs}"

            // cloning public sunbird-devops and private repo
            stage('checkout git') {
                    checkout scm
                    echo pipelineParams.branch
                    dir('sunbird-devops'){
                    git branch: pipelineParams.branch, url: pipelineParams.scmUrl
                    }
            }

            stage('Deploy') {
                    step ([$class: 'CopyArtifact',
                    projectName: pipelineParams.parentProject,
                    filter: pipelineParams.artifactName]);
                    sh deployScript
                    archiveArtifacts 'metadata.json'
            }
        }
    }
