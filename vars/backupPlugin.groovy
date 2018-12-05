// common plugin to clone code and build
def call(Map pipelineParams) {
def installDeps = libraryResource 'installDeps.sh'
    node(pipelineParams.agent){
            // cloning public sunbird-devops
        stage('checkout git') {
            // checkout scm
            // This should be replaced with above step
            git branch: 'release-1.12', url: 'https://github.com/ekstep/sunbird-devops', credentialsId: 'f37ad21f-744a-4817-9f5e-02f8ec620b39'
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
