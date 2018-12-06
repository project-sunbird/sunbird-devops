// common plugin to general ansible tasks
def call(body) {

    def installDeps = libraryResource 'installDeps.sh'
    def pipelineParams = [:]
    body.resolveStrategy = Closure.DELEGATE_FIRST
    body.delegate = pipelineParams
    body()

    node(pipelineParams.agent){
        // cloning public sunbird-devops and private repo
        stage('checkout git') {
            checkout scm
            dir('sunbird-devops'){
            git branch: pipelineParams.branch, url: pipelineParams.scmUrl
            }
        }

        stage('Backup') {
            sh """
            ansible-playbook -i ansible/inventories/${pipelineParams.env} \
            sunbird-devops/ansible/${pipelineParams.playBook} ${pipelineParams.ansibleExtraArgs}
            """
        }
    }
}
