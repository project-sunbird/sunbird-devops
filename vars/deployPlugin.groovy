def call(Map pipelineParams) { 
 node(pipelineParams.agent){             
         stage('checkout private repo') {
            dir('sunbird-devops-private'){
            git branch: pipelineParams.branch, url: pipelineParams.scmUrl, credentialsId: pipelineParams.credentials
            }
        }
            stage('Deploy') {
//                sh """ 
//                ansible-playbook -i $WORKSPACE/ansible/inventories/$pipelineParams.env \ 
//                $WORKSPACE/sunbird-devops/ansible/$pipelineParams.ansiblePlaybook \
//                --vault-password-file $pipelineParams.vaultFile
//                """
             println pipelineParams
            }
       }
}
