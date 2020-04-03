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
                if (!env.hub_org) {
                    println(ANSI_BOLD + ANSI_RED + '''\
                    Uh oh! Please set a Jenkins environment variable named hub_org with value as registery/sunbidrded
                    '''.stripIndent().replace("\n", " ") + ANSI_NORMAL)
                    error 'Please resolve errors and rerun..'
                } else
                    println(ANSI_BOLD + ANSI_GREEN + '''\
                    Found environment variable named hub_org with value as:
                    '''.stripIndent().replace("\n", " ") + hub_org + ANSI_NORMAL)

                if (params.absolute_job_path == "") {
                    println(ANSI_BOLD + ANSI_RED + '''\
                    Uh oh! Please specify the full path of the job from where the metedata.json file should be copied
                    '''.stripIndent().replace("\n", " ") + ANSI_NORMAL)
                    error 'Please resolve errors and rerun..'
                }
                values = [:]
                try {
                    copyArtifacts projectName: params.absolute_job_path, flatten: true
                }
                catch (err) {
                    println ANSI_YELLOW + ANSI_BOLD + "Ok that failed!. Lets try an alertnative.." + ANSI_NORMAL
                    copyArtifacts projectName: params.absolute_job_path, flatten: true, selector: upstream()
                }
                image_name = sh(returnStdout: true, script: 'jq -r .image_name metadata.json').trim()
                agent = sh(returnStdout: true, script: 'jq -r .node_name metadata.json').trim()

                if (params.image_tag == "") {
                    println(ANSI_BOLD + ANSI_YELLOW + '''\
                    image_tag not specified, using the image_tag specified in metadata.json.
                    '''.stripIndent().replace("\n", " ") + ANSI_NORMAL)
                    image_tag = sh(returnStdout: true, script: 'jq -r .image_tag metadata.json').trim()
                } else
                    image_tag = params.image_tag

                values.put('env', envDir)
                values.put('module', module)
                values.put('jobName', jobName)
                values.put('absolute_job_path', params.absolute_job_path)
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
