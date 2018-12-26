def call(){

    try {
        // Check if the job was triggered by an upstream project
        // If yes, get the name of the upstream project else job was started manually
        stage('check upstream') {
            values = [:]
            def upstream = currentBuild.rawBuild.getCause(hudson.model.Cause$UpstreamCause)
            triggerCause = upstream?.shortDescription
            if (triggerCause != null)
                triggerCause = triggerCause.split()[4].replaceAll('"', '')
            values.put('parent_project', triggerCause)
        }
        
        stage('parameter checks'){
            // Set Jenkins environment variable hub_org to registry_hub/sunbirded
            // If registry used is docker hub, registry_hub will be blank
            // If using azure hub, set registry_hub to azure repo path
            if (!env.hub_org)
                error 'Please set a Jenkins environment variable named hub_org and value as registry_hub/sunbirded'

            if (values.parent_project == null && (params.parent_project == "" || params.parent_project == null))
                error 'Please specify project name to copy metedata.json file as a job parameter'

            if (values.parent_project != null)
                copyArtifacts filter: 'metadata.json', projectName: values.parent_project
            else
                copyArtifacts filter: 'metadata.json', projectName: params.parent_project
            
            if (params.image_name == "") {
               println "Image name not specified, using the image name specified in metadata.json"
               image_name = sh(returnStdout: true, script: 'jq -r .image_name metadata.json').trim()
               println image_name
            }
            else
               image_name = params.image_name
            
            if (params.image_tag == "") {
               println "Image tag not specified, using the version specified in metadata.json"
               image_tag = sh(returnStdout: true, script: 'jq -r .image_tag metadata.json').trim()
            }
            else
               image_tag = params.image_tag
            
            agent = sh(returnStdout: true, script: 'jq -r .nodeName metadata.json').trim()
            values.put('image_name', image_name)
            values.put('image_tag', image_tag)
            values.put('hub_org', hub_org)
            values.put('agent', agent)
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
