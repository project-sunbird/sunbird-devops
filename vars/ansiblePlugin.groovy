def call(body) {

   def pipelineParams = [:]
   body.resolveStrategy = Closure.DELEGATE_FIRST
   body.delegate = pipelineParams
   body()

   node(pipelineParams.agent){
       // cloning public sunbird-devops and private repo
       stage('checkout git') {
           checkout scm
           dir('sunbird-devops'){
           git branch: pipelineParams.branch, url: pipelineParams.scmUrl, credentialsId: 'f37ad21f-744a-4817-9f5e-02f8ec620b39'
           }
       }

       stage('Push') {
           sh """
           ansible-playbook -i ansible/inventories/${pipelineParams.env} \
           sunbird-devops/ansible/${pipelineParams.playBook} ${pipelineParams.ansibleExtraArgs}
           """
       }
   }
