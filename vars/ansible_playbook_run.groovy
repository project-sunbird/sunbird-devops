// common plugin to general ansible tasks
def call(Map pipelineParams) {
    node(pipelineParams.agent){
        try {
            ansiColor('xterm') {
                String ANSI_GREEN = "\u001B[32m"
                String ANSI_NORMAL = "\u001B[0m"
                String ANSI_BOLD = "\u001B[1m"
                String ANSI_RED = "\u001B[31m"
                String ANSI_YELLOW = "\u001B[33m"
                // cloning public sunbird-devops and private repo
                stage('checkout private repo') {
                    dir("$pipelineParams.currentWs/private") {
                        if (params.inventory_source == "GitHub") {
                            if (!env.private_repo_url || !env.private_repo_branch || !env.private_repo_credentials) {
                                println(ANSI_BOLD + ANSI_RED + '''\
                               Uh Oh! Option seleted is GitHub. Please create Jenkins environment variables named
                               private_repo_url, private_repo_branch, private_repo_credentials
                               '''.stripIndent().replace("\n", " ") + ANSI_NORMAL)
                                error 'Please resolve errors and rerun..'
                            }
                            git branch: private_repo_branch, url: private_repo_url, credentialsId: private_repo_credentials
                        } else
                            println(ANSI_BOLD + ANSI_YELLOW + '''\
                            Option selected is Local. Using the local inventory specified in inventory_path
                            '''.stripIndent().replace("\n", " ") + ANSI_NORMAL)

                        if (params.inventory_path == "") {
                            println(ANSI_BOLD + ANSI_RED + """\
                                   Uh Oh! Please specify the absolute path to the inventory file directory.
                                   If inventory is GitHub, please specifiy inventory path as 
                                   $WORKSPACE/private/path_to_inventory
                                   """.stripIndent().replace("\n", " ") + ANSI_NORMAL)
                        }
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
        }
            catch (err){
                throw err
            }
        }
    }
