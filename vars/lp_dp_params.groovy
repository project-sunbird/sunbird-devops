def call(){
    try {
        String ANSI_GREEN = "\u001B[32m"
        String ANSI_NORMAL = "\u001B[0m"
        String ANSI_BOLD = "\u001B[1m"
        String ANSI_RED = "\u001B[31m"
        String ANSI_YELLOW = "\u001B[33m"

        envDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-3].trim()
        module = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-2].trim()
        jobName = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-1].trim()

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

                // Error handling for az details needs to go here if required

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
                values.put('module', module)
                values.put('jobName', jobName)
                values.put('agent', agent)
                values.put('artifact_name', artifact_name)
                values.put('artifact_version', artifact_version)
                return values
            }
        }
    }

    catch (err) {
        throw err
    }
}
