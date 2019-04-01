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

                // cloning private repo
                stage('checkout private repo') {
                    dir("$pipelineParams.currentWs/private") {
                            if (!env.private_repo_url || !env.private_repo_branch || !env.private_repo_credentials) {
                                println(ANSI_BOLD + ANSI_RED + '''\
                               Uh Oh! Please create Jenkins environment variables named
                               private_repo_url, private_repo_branch, private_repo_credentials
                               '''.stripIndent().replace("\n", " ") + ANSI_NORMAL)
                                error 'Please resolve errors and rerun..'
                            }
                            def checkDir = new File('../private')
                            println params.private_branch
                            if(params.private_branch != null || params.private_branch != "")
                               env.private_repo_branch = params.private_branch
                            if(!checkDir.exists())
                                checkout scm: [$class: 'GitSCM', branches: [[name: private_repo_branch]], extensions: [[$class: 'GitLFSPull'], [$class: 'CloneOption', depth: 1, noTags: true, reference: '', shallow: true]], userRemoteConfigs: [[credentialsId: private_repo_credentials, url: private_repo_url]]]
                            else
                                println(ANSI_BOLD + ANSI_YELLOW + 'Github repo already exists. Not cloning again' + ANSI_NORMAL)
                    }
                }

                stage('ansible-playbook') {
                    println pipelineParams
                    ansiColor('xterm') {
                        sh """
                            cp ${pipelineParams.currentWs}/private/ansible/inventory/${pipelineParams.env}/${pipelineParams.module}/* ${pipelineParams.currentWs}/ansible/inventory/env/
                        """
                        inventory_path = "${pipelineParams.currentWs}/ansible/inventory/env"
                        sh """
                               ansible-playbook -i ${inventory_path} \
                               $pipelineParams.ansiblePlaybook $pipelineParams.ansibleExtraArgs
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
