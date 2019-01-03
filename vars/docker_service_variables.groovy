def call(){

    try {
        jobname = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-1].trim()
        envDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-2].trim()
        if (params.size() == 0){
            properties([[$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false], 
            parameters([string(defaultValue: '', description: '<font color=teal size=2>The metadata.json file of the last successful build will be copied from this job. Please specify the absolute path to the job.</font>', name: 'copy_metadata_from', trim: false),
            string(defaultValue: '', description: '<font color=teal size=2>Specify only version/tag, image name will be picked from the metadata.json file. If the value is blank, version will be picked from the metadata.json file.</font>', name: 'image_tag', trim: false),
            [$class: 'CascadeChoiceParameter', choiceType: 'PT_SINGLE_SELECT', description: '',
            filterLength: 1, filterable: false, name: 'inventory_source', randomName: 'choice-parameter-330141505859086',
            referencedParameters: '', script: [$class: 'GroovyScript', fallbackScript: [classpath: [], sandbox: false,
            script: ''], script: [classpath: [], sandbox: false, script: 'return [\'GitHub\', \'Local\']']]],
            [$class: 'DynamicReferenceParameter', choiceType: 'ET_FORMATTED_HTML', description: '<font color=teal size=2>If your ansible inventory is stored on github, choose github. If your ansible inventory is stored locally, choose local.</font>',
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
            string(defaultValue: "$WORKSPACE/private/ansible/inventories/$envDir", description: '<font color=teal size=2>Please sepecify the full path to the inventory directory. The default value is $WORKSPACE/private/ansible/env. Here env is the previous directory of the job.</font>', name: 'inventory_path', trim: false)])])

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
            if(!env.hub_org)
               error 'Please create a Jenkins environment variabled named hub_org with value as registry/sunbirded.'
            
            if (values.copy_metadata_from == null && params.copy_metadata_from == "")
                error 'Please specify project name to copy metedata.json file.'

            if (values.copy_metadata_from != null){
                copyArtifacts filter: 'metadata.json', projectName: values.copy_metadata_from
                params.copy_metadata_from = values.copy_metadata_from
            }
            else {
                copyArtifacts filter: 'metadata.json', projectName: params.copy_metadata_from
                values.put('copy_metadata_from', params.copy_metadata_from)
            }
            
            image_name = sh(returnStdout: true, script: 'jq -r .image_name metadata.json').trim()
                
            if (params.image_tag == "") {
               println "image_tag not specified, using the image_tag specified in metadata.json."
               image_tag = sh(returnStdout: true, script: 'jq -r .image_tag metadata.json').trim()
            }
            else
               image_tag = params.image_tag
            
            agent = sh(returnStdout: true, script: 'jq -r .node_name metadata.json').trim()
            values.put('env', envDir)
            values.put('agent', agent)
            values.put('image_name', image_name)
            values.put('image_tag', image_tag)
            return values
        }
    }
    catch (err){
        throw err
    }
}
