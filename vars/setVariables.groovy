def call(){

  // Check if the job was triggered by an upstream project
  // If yes, get the name of the upstream project else job was started manually
  stage('check trigger'){
    values = [:]
    def upstream = currentBuild.rawBuild.getCause(hudson.model.Cause$UpstreamCause)
    triggerCause = upstream?.shortDescription
    if (triggerCause == null)
       triggerCause = "manual"
    else
      triggerCause = triggerCause.split()[4].replaceAll('"', '')
    values.put('metadataPath', triggerCause)
    println triggerCause
  }
  
  // Get the parent dir of where the job resides. This will be used to obtain the inventory file
  stage('get job name and parent dir'){
    listLength = sh(returnStdout: true, script: "echo $JOB_NAME").split('/').length
    parentDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[length - 2].trim()
    env.jobname = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[length -1].split('_')[0].trim()
    println parentDir
    println jobname
    values.put('env', parentDir)
  }
  
  // Parse the json property file and append the values to the map. This will make use of the job name
  // First part of job name should match the name provided in the json file
  // Example - player_build, player_deploy
  stage('append map values'){
    println private_repo_branch
    ansiblePlaybook = sh(returnStdout: true, script: 'jq -r .$jobname.playbook properties.json')
    scmUrl = sh(returnStdout: true, script: 'jq -r .$jobname.scmUrl properties.json')
    vaultFile = sh(returnStdout: true, script: 'jq -r .$jobname.vaultFile properties.json')
    values.put('ansiblePlaybook', ansiblePlaybook)
    values.put('scmUrl', scmUrl)
    values.put('vaultFile', vaultFile)
    values.put('branch', private_repo_branch)
    if (private_credentials == "")
       values.put('credentials', 'f37ad21f-744a-4817-9f5e-02f8ec620b39')
    else
      values.put('credentials', private_credentials)
    return values
  }
}

