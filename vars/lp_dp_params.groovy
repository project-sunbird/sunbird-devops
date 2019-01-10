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
            properties([[$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false], parameters([string(defaultValue: '',
                    description: '<font color=teal size=2>Please specify the absolute path to the job from which the metadata.json will be copied.</font>',
                    name: 'copy_metadata_from', trim: false), string(defaultValue: 'lastSuccessfulBuild',
                    description: '<font color=teal size=2>Specify the build number to copy the artifact from. Default is last successful build of the job</font>',
                    name: 'build_number', trim: false), choice(choices: ['Remote', 'Local'], description: '<font color=teal size=2>Choose the artifact source</font>',
                    name: 'artifact_source'), string(defaultValue: '', description: '<font color=teal size=2>Specify only version, artifact name will be picked from the metadata.json file. If the value is blank, version will be picked from the metadata.json file.</font>',
                    name: 'artifact_version', trim: false), string(defaultValue: '', description: '<font color=teal size=2>Specify the azure blob container to push / pull the artifact from</font>', name: 'azure_container_name', trim: false),
                    choice(choices: ['GitHub', 'Local'], description: '<font color=teal size=2>Choose the ansible inventory source</font>',
                    name: 'inventory_source'), string(defaultValue: "$WORKSPACE/private/ansible/inventories/$envDir",
                    description: '<font color=teal size=2>Please sepecify the full path to the inventory directory. The default value is $WORKSPACE/private/ansible/env. Here env is the previous directory of the job.</font>',
                    name: 'inventory_path', trim: false)])])
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

        stage('parameter checks') {
            ansiColor('xterm') {
                if (values.copy_metadata_from == null && params.copy_metadata_from == ""){
                    println (ANSI_BOLD + ANSI_RED + '''\
                    Uh oh! Please specify the full path of the job from where the metedata.json file should be copied
                    '''.stripIndent().replace("\n", " ") + ANSI_NORMAL)
                    error 'Please resolve errors and rerun..'
                }

                if(params.azure_container == "" && params.artifact_source == "Remote"){
                    println (ANSI_BOLD + ANSI_RED + '''\
                    Uh oh! Option selected is Remote. Please specify the azure container name
                    '''.stripIndent().replace("\n", " ") + ANSI_NORMAL)
                    error 'Please resolve errors and rerun..'
                }

                // Error handling for blob details needs to go here if required

                if (values.copy_metadata_from != null){
                    copyArtifacts projectName: values.copy_metadata_from, fingerprintArtifacts: true, flatten: true, selector: specific(params.build_number)
                }
                else {
                    copyArtifacts projectName: params.copy_metadata_from, fingerprintArtifacts: true, flatten: true, selector: specific(params.build_number)
                    values.put('copy_metadata_from', params.copy_metadata_from)
                }

                artifact_name = sh(returnStdout: true, script: 'jq -r .artifact_name metadata.json').trim()

                if (params.artifact_version == "") {
                    println (ANSI_BOLD + ANSI_YELLOW + '''\
                    artifact_version not specified, using the artifact_version specified in metadata.json.
                    '''.stripIndent().replace("\n", " ") + ANSI_NORMAL)
                    artifact_version = sh(returnStdout: true, script: 'jq -r .artifact_version metadata.json').trim()
                }
                else
                    artifact_version = params.artifact_version

                agent = sh(returnStdout: true, script: 'jq -r .node_name metadata.json').trim()
                values.put('env', envDir)
                values.put('agent', agent)
                values.put('artifact_name', artifact_name)
                values.put('artifact_version', artifact_version)
            }
        }
    }

    catch (err) {
        throw err
    }
}
