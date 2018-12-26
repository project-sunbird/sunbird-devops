def call(){

    try {
        // Check if the job was triggered by an upstream project
        // If yes, get the name of the upstream project else job was started manually
        stage('check upstream') {
            if (!env.hub_org)
                error 'Please set a Jenkins environment variable named hub_org and value as sunbird'
            values = [:]
            def upstream = currentBuild.rawBuild.getCause(hudson.model.Cause$UpstreamCause)
            triggerCause = upstream?.shortDescription
            if (triggerCause != null)
                triggerCause = triggerCause.split()[4].replaceAll('"', '')
            values.put('parentProject', triggerCause)
        }

        stage('read properties') {
            // Get the parent dir of where the job resides. This will be used to obtain the inventory file
            envDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-3].trim()
            env.jobname = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-1].split('_')[0].trim()
            values.put('env', envDir)

            def file = new File("$WORKSPACE/properties.json")
            if(!file.exists())
                error 'properties.json file is missing in projects root directoy'

            // Parse the json property file and append the values to the map. This will make use of the job name
            // Job name should match the name provided in the json file
            // Example - player_build, player_deploy
            // Common for all services
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
            return values
        }
    }
    catch (err){
        throw err
    }
}
