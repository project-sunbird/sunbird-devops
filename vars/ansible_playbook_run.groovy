def call(Map pipelineParams) {
    try {
        ansiColor('xterm') {
            String ANSI_GREEN = "\u001B[32m"
            String ANSI_NORMAL = "\u001B[0m"
            String ANSI_BOLD = "\u001B[1m"
            String ANSI_RED = "\u001B[31m"
            String ANSI_YELLOW = "\u001B[33m"

            stage('ansible-run') {
                println pipelineParams
                dir("$pipelineParams.currentWs/private") {
                    if (!env.private_repo_url || !env.private_repo_branch || !env.private_repo_credentials) {
                        println(ANSI_BOLD + ANSI_RED + '''\
                               Uh Oh! Please create Jenkins environment variables named
                               private_repo_url, private_repo_branch, private_repo_credentials
                               '''.stripIndent().replace("\n", " ") + ANSI_NORMAL)
                        error 'Please resolve errors and rerun..'
                    }

                    if (params.private_branch != null && params.private_branch != "") {
                        env.private_repo_branch = params.private_branch
                        println(ANSI_BOLD + ANSI_YELLOW + 'Info: Branch override is enabled' + ANSI_NORMAL)
                    } else
                        println(ANSI_BOLD + ANSI_YELLOW + 'Info: Branch override is disabled' + ANSI_NORMAL)

                    checkout scm: [$class: 'GitSCM', branches: [[name: private_repo_branch]], extensions: [[$class: 'CloneOption', depth: 1, noTags: true, reference: '', shallow: true]], userRemoteConfigs: [[credentialsId: private_repo_credentials, url: private_repo_url]]]
                }

                inventory_path = "${pipelineParams.currentWs}/ansible/inventory/env"
                sh """
                        rsync -Lkr ${pipelineParams.currentWs}/private/ansible/inventory/${pipelineParams.env}/${pipelineParams.module}/* ${pipelineParams.currentWs}/ansible/inventory/env/
                        if [ -f ${pipelineParams.currentWs}/ansible/inventory/env/kubernetes.yaml ]; then
                            cat ${pipelineParams.currentWs}/ansible/inventory/env/kubernetes.yaml >> ${pipelineParams.currentWs}/ansible/inventory/env/common.yml
                        fi
                        ansible-playbook -i ${inventory_path} $pipelineParams.ansiblePlaybook $pipelineParams.ansibleExtraArgs
                     """
            }
        }
    }
    catch (err){
        throw err
    }
}
