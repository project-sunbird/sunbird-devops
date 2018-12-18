def call(){

  // Check if the job was triggered by an upstream project
  // If yes, get the name of the upstream project else job was started manually
  stage('check trigger'){
    values = [:]
    def upstream = currentBuild.rawBuild.getCause(hudson.model.Cause$UpstreamCause)
    triggerCause = upstream?.shortDescription
    if (triggerCause != null)
         triggerCause = triggerCause.split()[4].replaceAll('"', '')
    values.put('metadataFile', triggerCause)
    println triggerCause
  }
  
  // Get the parent dir of where the job resides. This will be used to obtain the inventory file
  stage('check env'){
    parentDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-2].trim()
    env.jobname = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-1].trim()
    println parentDir
    println jobname
    values.put('env', parentDir)
  }
  
  // Parse the json property file and append the values to the map. This will make use of the job name
  // First part of job name should match the name provided in the json file
  // Example - player_build, player_deploy
  stage('read props'){
    // Common
    scmUrl = sh(returnStdout: true, script: 'jq -r .common.scmUrl properties.json').trim()
    vaultFile = sh(returnStdout: true, script: 'jq -r .common.vaultFile properties.json').trim()
    
    // Job specific
    ansiblePlaybook = sh(returnStdout: true, script: 'jq -r .$jobname.playbook properties.json').trim()
    serviceName = sh(returnStdout: true, script: 'jq -r .$jobname.serviceName properties.json').trim()
    deployExtraArgs = sh(returnStdout: true, script: 'jq -r .$jobname.deployExtraArgs properties.json').trim()
    
    values.put('scmUrl', scmUrl)
    values.put('vaultFile', vaultFile)
    values.put('ansiblePlaybook', ansiblePlaybook)
    values.put('serviceName', serviceName)
    values.put('deployExtraArgs', deployExtraArgs)
    values.put('branch', private_repo_branch)
    
    println private_credentials
    values.put('credentials', private_credentials)
    return values
  }
}
