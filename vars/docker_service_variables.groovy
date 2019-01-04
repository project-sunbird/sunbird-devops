def call(){

    try {
        String ANSI_GREEN = "\u001B[32m"
        String ANSI_NORMAL = "\u001B[0m"
        String ANSI_BOLD = "\u001B[1m"
        String ANSI_RED = "\u001B[31m"
        String ANSI_YELLOW = "\u001B[33m"
        jobname = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-1].trim()
        envDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-2].trim()
        if (params.size() == 0){
            properties([[$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false],
                        parameters([string(defaultValue: '', description: '<font color=teal size=2>The metadata.json file of the last successful build will be copied from this job. Please specify the absolute path to the job.</font>', name: 'copy_metadata_from', trim: false),
                                    string(defaultValue: '', description: '<font color=teal size=2>Specify only version/tag, image name will be picked from the metadata.json file. If the value is blank, version will be picked from the metadata.json file.</font>', name: 'image_tag', trim: false),
                                    choice(choices: ['GitHub', 'Local'], description: '<font color=teal size=2>Choose the ansible inventory source</font>', name: 'inventory_source'),
                                    string(defaultValue: "$WORKSPACE/private/ansible/inventories/$envDir", description: '<font color=teal size=2>Please sepecify the full path to the inventory directory. The default value is $WORKSPACE/private/ansible/env. Here env is the previous directory of the job.</font>', name: 'inventory_path', trim: false)])])
            ansiColor('xterm') {
                println (ANSI_BOLD + ANSI_GREEN + '''\
                        First run of the job. Parameters created. Stopping the current build.
                        Please trigger new build and provide parameters if required.
                        '''.stripIndent().replace("\n"," ") + ANSI_NORMAL)
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
            ansiColor('xterm') {
                if(env.hub_org){
                    println (ANSI_BOLD + ANSI_RED + '''\
                    Uh oh! Please set a Jenkins environment variable named hub_org with value as registery/sunbidrded
                    '''.stripIndent().replace("\n", " ") + ANSI_NORMAL)
                    error 'Please resolve errors and rerun..'
                }
                else
                    println (ANSI_BOLD + ANSI_GREEN + '''\
                    Found environment variable named hub_org with value as:  
                    '''.stripIndent().replace("\n", " ") + hub_org + ANSI_NORMAL)

                if (values.copy_metadata_from == null && params.copy_metadata_from == ""){
                    println (ANSI_BOLD + ANSI_RED + '''\
                    Uh oh! Please specify the full path of the job from where the metedata.json file should be copied
                    '''.stripIndent().replace("\n", " ") + ANSI_NORMAL)
                    error 'Please resolve errors and rerun..'
                }

                if (values.copy_metadata_from != null){
                    copyArtifacts filter: 'metadata.json', projectName: values.copy_metadata_from
                }
                else {
                    copyArtifacts filter: 'metadata.json', projectName: params.copy_metadata_from
                    values.put('copy_metadata_from', params.copy_metadata_from)
                }

                image_name = sh(returnStdout: true, script: 'jq -r .image_name metadata.json').trim()

                if (params.image_tag == "") {
                    println (ANSI_BOLD + ANSI_YELLOW + '''\
                    image_tag not specified, using the image_tag specified in metadata.json.
                    '''.stripIndent().replace("\n", " ") + ANSI_NORMAL) 
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
    }
    catch (err){
        throw err
    }
}
