// common plugin to general ansible tasks
def call(Map pipelineParams) {
    node(pipelineParams.agent){
        try {
            // cloning public sunbird-devops and private repo
            stage('checkout private repo') {
                
                if(params.inventory_path == "")
                    error """\
                           Please specify the absolute path to the inventory file directory for option Local.
                           If option selected is GitHub, please specifiy inventory path as 
                           $WORKSPACE/private/path_to_inventory
                           """.stripIndent().replace("\n"," ")
                    
                if(params.inventory_source == 'GitHub'){
                    paramsSize = params.git_info.split(',').size()
                    if(paramsSize != 2)
                      error '''\
                              GitHub option selected during build. Please specify the GitHub URL and Branch to checkout
                              You can also set these two values as environment variables with variable name as 
                              private_repo_url and private_repo_branch
                              '''.stripIndent().replace("\n"," ")
                }
                    if(!env.private_repo_credentials)
                       error '''\
                               Please create a Jenkins environment variable named private_repo_credentials with 
                               value being the credential id
                               '''.stripIndent().replace("\n"," ")
                    scmUrl = params.git_info.split(',')[0]
                    scmBranch = params.git_info.split(',')[1]
                dir('private') {
                    git branch: scmBranch, url: scmUrl, credentialsId: private_repo_credentials
                }
            }

            stage('ansible-playbook') {
               println pipelineParams
//               sh """
//               ansible-playbook -i $WORKSPACE/sunbird-devops-private/ansible/inventories/$pipelineParams.env \
//               $WORKSPACE/ansible/$pipelineParams.ansiblePlaybook $pipelineParams.ansibleExtraArgs
//               """
            }
        }
        catch (err){
            throw err
        }
    }
}
