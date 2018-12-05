// common plugin to clone code and build
def call(Map pipelineParams) {
def installDeps = libraryResource 'installDeps.sh'
    node(pipelineParams.agent){
        // cloning public sunbird-devops
        stage('checkout git') {
            checkout scm
            dir('sunbird-devops'){
            git branch: pipelineParams.branch, url: pipelineParams.scmUrl
            }
        }

        stage('Backup') {
            sh """
            ls
            apk -v --update --no-cache add ansible jq
            ansible-playbook -i ansible/inventories/${pipelineParams.env} sunbird-devops/ansible/${pipelineParams.playBook} ${pipelineParams.ansibleExtraArgs}
            """
        }
    }
}
