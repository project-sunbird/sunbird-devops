// common plugin to general ansible tasks
def call(Map pipelineParams) {
    node(pipelineParams.agent){
        try {
            // cloning public sunbird-devops and private repo
            stage('checkout private repo') {
                dir("$pipelineParams.currentWs/private") {
                    if (params.inventory_source == "GitHub") {
                        if (!env.private_repo_url || !env.private_repo_branch || !env.private_repo_credentials)
                            error '''\
                               Option seleted is GitHub. Please create Jenkins environment variables named 
                               private_repo_url, private_repo_branch, private_repo_credentials.
                               '''.stripIndent().replace("\n", " ")
                        git branch: private_repo_branch, url: private_repo_url, credentialsId: private_repo_credentials
                    } 
                    else
                        println "Option selected is Local. Using the local inventory specified in inventory_path"

                    if (params.inventory_path == "")
                        error """\
                                   Please specify the absolute path to the inventory file directory.
                                   If inventory is GitHub, please specifiy inventory path as 
                                   $WORKSPACE/private/path_to_inventory
                                   """.stripIndent().replace("\n", " ")
                }
            }

            stage('ansible-playbook') {
                println pipelineParams
                ansiColor('xterm') {
                    sh """
               ansible-playbook -i $params.inventory_path \
               $pipelineParams.currentWs/ansible/$pipelineParams.ansiblePlaybook $pipelineParams.ansibleExtraArgs
               """
                }
            }
        }
        catch (err){
            throw err
        }
    }
}
