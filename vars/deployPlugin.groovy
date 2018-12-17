def call(Map pipelineParams) { 
 node(pipelineParams.agent){             
         stage('checkout private repo') {
            dir('sunbird-devops-private'){
            git branch: pipelineParams.branch, url: pipelineParams.scmUrl, credentialsId: pipelineParams.credentials
            }
        }
            stage('Deploy') {
                org = sh(returnStdout: true, script: 'jq -r .org metadata.json').trim()
                name = sh(returnStdout: true, script: 'jq -r .name metadata.json').trim()
                version= sh(returnStdout: true, script: 'jq -r .version metadata.json').trim()
                artifactLabel = sh(returnStdout: true, script: '${pipelineParams.artifactLabel:-bronze}').trim()
                environ = sh(returnStdout: true, script: '${pipelineParams.env:-null}').trim()

                println "artifactLabel:  $artifactLabel"
                println "env:            $environ"
                println "org:            $org"
                println "name:           $name"
                println "version:        $version"
                println "ANSIBLE_PATH:   $ANSIBLE_PATH"

                println pipelineParams    
//                sh """ 
//                ansible-playbook -i $WORKSPACE/ansible/inventories/$environ \ 
//                $WORKSPACE/sunbird-devops/ansible/$pipelineParams.ansiblePlaybook \
//                --tags "stack-sunbird" --extra-vars "hub_org=$org image_name=$name image_tag=$version-$artifactLabel \
//                service_name=$pipelineParams.serviceName $pipelineParams.deployExtraArgs" \
//                --vault-password-file $pipelineParams.vaultFile
//                """
            }
       }
}
