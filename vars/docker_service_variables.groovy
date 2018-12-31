def call(){

    try {
        jobname = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-1].trim()
        if (params.size() == 0){
            properties([[$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false], 
            parameters([[$class: 'WHideParameterDefinition', defaultValue: "$jobname", description: '', 
            name: 'docker_service_name'], 
            string(defaultValue: '', description: '', name: 'docker_service_version', trim: false), 
            string(defaultValue: '', description: '', name: 'copy_metadata_from', trim: false), 
            [$class: 'WHideParameterDefinition', defaultValue: 'sunbirded.azurecr.io/sunbirded', description: '', 
            name: 'hub_org'], 
            [$class: 'CascadeChoiceParameter', choiceType: 'PT_SINGLE_SELECT', description: '', 
            filterLength: 1, filterable: false, name: 'inventory_source', randomName: 'choice-parameter-330141505859086', 
            referencedParameters: '', script: [$class: 'GroovyScript', fallbackScript: [classpath: [], sandbox: false, 
            script: ''], script: [classpath: [], sandbox: false, script: 'return [\'GitHub\', \'Local\']']]], 
            [$class: 'DynamicReferenceParameter', choiceType: 'ET_FORMATTED_HTML', description: '', 
            name: 'git_info', omitValueField: true, randomName: 'choice-parameter-330141508543294', 
            referencedParameters: 'inventory_source', 
           
            script: [$class: 'GroovyScript', fallbackScript: [classpath: [], sandbox: false, script: 
            '''def gitUrl = "", gitBranch = ""
            if(inventory_source.equals(\'GitHub\')){
            return "<b>Git URL</b><input name=\\"value\\" value=\\"${gitUrl}\\" class=\\"setting-input\\" type=\\"text\\"/> <b>Branch</b><input name=\\"value\\" value=\\"${gitBranch}\\" class=\\"setting-input\\" type=\\"text\\"/>"}
            else
            return "<b>Not Applicable</b><input name=\\"value\\" value=\\"NA\\" type=\\"hidden\\"/>"'''], 
                 
            script: [classpath: [], sandbox: false, script: 
            '''def gitUrl = "${private_repo_url}", gitBranch = "${private_repo_branch}"
            if(inventory_source.equals(\'GitHub\')){
            return "<b>Git URL</b><input name=\\"value\\" value=\\"${gitUrl}\\" class=\\"setting-input\\" type=\\"text\\"/> <b>Branch</b><input name=\\"value\\" value=\\"${gitBranch}\\"  class=\\"setting-input\\" type=\\"text\\"/>"}
            else
            return "<b>Not Applicable</b><input name=\\"value\\" value=\\"NA\\" type=\\"hidden\\"/>"''']]], 
            
            string(defaultValue: '', description: '', name: 'inventory_path', trim: false)])])

            ansiColor('xterm') {
              println '''\
                        First run of the job. Parameters created. Stopping the current build. 
                        Please trigger new build and provide parameters if required.
                        '''.stripIndent().replace("\n"," ")
            }
            return "first run"
        }
        
        
        // Check if the job was triggered by an upstream project
        // If yes, get the name of the upstream project else job was started manually
        stage('check upstream') {
            values = [:]
            def upstream = currentBuild.rawBuild.getCause(hudson.model.Cause$UpstreamCause)
            triggerCause = upstream?.shortDescription
            if (triggerCause != null)
                triggerCause = triggerCause.split()[4].replaceAll('"', '')
            values.put('copy_metadata_from', triggerCause)
        }
        
        stage('parameter checks'){
            if (values.copy_metadata_from == null && params.copy_metadata_from == "")
                error 'Please specify project name to copy metedata.json file.'

            if (values.copy_metadata_from != null)
                copyArtifacts filter: 'metadata.json', projectName: values.copy_metadata_from
            else
                copyArtifacts filter: 'metadata.json', projectName: params.copy_metadata_from
            
            if (params.docker_service_name != jobname)
                error 'Job name and hidden job parameter docker_service_name default value do not match.'
                
            if (params.docker_service_version == "") {
               println """Version for docker service - $params.docker_service_version not specified, 
                        using the version specified in metadata.json"""
               docker_service_version = sh(returnStdout: true, script: 'jq -r .image_tag metadata.json').trim()
            }
            else
               docker_service_version = params.docker_service_version
            
            envDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-2].trim()
            agent = sh(returnStdout: true, script: 'jq -r .node_name metadata.json').trim()
            values.put('env', envDir)
            values.put('agent', agent)
            values.put('docker_service_name', params.docker_service_name)
            values.put('docker_service_version', params.docker_service_version)
            values.put('hub_org', params.hub_org)
            return values
        }
    }
    catch (err){
        throw err
    }
}
