def call(){
    try {
        ansiColor('xterm') {
            String ANSI_GREEN = "\u001B[32m"
            String ANSI_NORMAL = "\u001B[0m"
            String ANSI_BOLD = "\u001B[1m"
            String ANSI_RED = "\u001B[31m"
            String ANSI_YELLOW = "\u001B[33m"

            envDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-3].trim()
            module = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-2].trim()
            jobName = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-1].trim()

            stage('parameter checks') {
                if (params.absolute_job_path == "") {
                    println(ANSI_BOLD + ANSI_RED + '''\
                    Uh oh! Please specify the full path of the job from where the metedata.json file should be copied
                    '''.stripIndent().replace("\n", " ") + ANSI_NORMAL)
                    error 'Please resolve errors and rerun..'
                }

                if (params.build_number == "") {
                    println(ANSI_BOLD + ANSI_YELLOW + '''\
                   Setting build_number to lastSuccessfulBuild to copy metadata.json
                    '''.stripIndent().replace("\n", " ") + ANSI_NORMAL)
                    buildNumber = "lastSuccessfulBuild"
                } else
                    buildNumber = params.build_number

                values = [:]
                try {
                    copyArtifacts projectName: params.absolute_job_path, fingerprintArtifacts: true, flatten: true, selector: specific(buildNumber)
                }
                catch (err) {
                    println ANSI_YELLOW + ANSI_BOLD + "Ok that failed!. Lets try an alertnative.." + ANSI_YELLOW
                    copyArtifacts projectName: params.absolute_job_path, fingerprintArtifacts: true, flatten: true, selector: upstream()
                }
                artifact_name = sh(returnStdout: true, script: 'jq -r .artifact_name metadata.json').trim()
                agent = sh(returnStdout: true, script: 'jq -r .node_name metadata.json').trim()

                if (params.artifact_version == "" || params.artifact_version == null) {
                    println(ANSI_BOLD + ANSI_YELLOW + '''\
                    artifact_version not specified, using the artifact_version specified in metadata.json.
                    '''.stripIndent().replace("\n", " ") + ANSI_NORMAL)
                    artifact_version = sh(returnStdout: true, script: 'jq -r .artifact_version metadata.json').trim()
                } else
                    artifact_version = params.artifact_version

                values.put('env', envDir)
                values.put('module', module)
                values.put('jobName', jobName)
                values.put('absolute_job_path', params.absolute_job_path)
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
