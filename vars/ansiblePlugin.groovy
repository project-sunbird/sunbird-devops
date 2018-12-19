// common plugin to general ansible tasks
def call(Map pipelineParams) {
    node(pipelineParams.agent){
        try {
            // cloning public sunbird-devops and private repo
            stage('checkout private repo') {

                if (!env.private_repo_branch && (params.private_repo_branch == "" || params.private_repo_branch == null))
                    error 'Please specify private repo branch to checkout as a parameter to job or set it as a Jenkins environment variable'

                if (params.private_repo_branch != "" && params.private_repo_branch != null)
                    pipelineParams.put('privateBranch', params.private_repo_branch)
                else if (env.private_repo_branch) {
                    pipelineParams.put('privateBranch', private_repo_branch)
                    println "Branch not specified as a parameter, checking out branch specified as environment variable - $private_repo_branch"
                }
                dir('sunbird-devops-private') {
                    git branch: pipelineParams.privateBranch, url: pipelineParams.scmUrl, credentialsId: private_repo_credentials
                }
            }

            stage('ansible-playbook') {
                println pipelineParams
//            sh """
//            ansible-playbook -i $WORKSPACE/sunbird-devops-private/ansible/inventories/$pipelineParams.env \
//            $WORKSPACE/ansible/$pipelineParams.ansiblePlaybook $pipelineParams.ansibleExtraArgs
//            """
            }
        }
        catch (err){
            throw err
        }
    }
}
