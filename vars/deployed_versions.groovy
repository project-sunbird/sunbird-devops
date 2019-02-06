def call() {
    try {
        String ANSI_GREEN = "\u001B[32m"
        String ANSI_NORMAL = "\u001B[0m"
        String ANSI_BOLD = "\u001B[1m"
        String ANSI_RED = "\u001B[31m"
        String ANSI_YELLOW = "\u001B[33m"

        stage('check upstream') {
            values = [:]
            upstream = currentBuild.rawBuild.getCause(hudson.model.Cause$UpstreamCause)
            triggerCause = upstream?.shortDescription
            if (triggerCause != null)
                triggerCause = triggerCause.split()[4].replaceAll('"', '')
            values.put('absolute_job_path', triggerCause)
        }

        stage('Write data')
                {
                    envDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-3].trim()
                    if (values.absolute_job_path != null) {
                        module = values.absolute_job_path.split('/')[-2].toString().trim()
                        jobName = values.absolute_job_path.split('/')[-1].toString().trim()
                        println envDir + " " + module + " " + jobName

                        copyArtifacts projectName: values.absolute_job_path, fingerprintArtifacts: true, flatten: true, filter: 'metadata.json'

                        sh """
                        mkdir -p ${JENKINS_HOME}/summary/${envDir}
                        touch -a ${JENKINS_HOME}/summary/${envDir}/summary.txt
                        sed -i "s/${jobName}.*//g" ${JENKINS_HOME}/summary/${envDir}/summary.txt
                        sed -i "/^\\\$/d" ${JENKINS_HOME}/summary/$envDir}/summary.txt
                        """

                        if (module == "Core") {
                            image_name = sh(returnStdout: true, script: 'jq -r .image_name metadata.json').trim()
                            image_tag = sh(returnStdout: true, script: 'jq -r .image_tag metadata.json').trim()
                            println image_name + " " + image_tag
                            sh """
                          echo "${image_name} : ${image_tag}" >> $JENKINS_HOME/summary/${envDir}/summary.txt
                            """
                        } else {
                            artifact_version = sh(returnStdout: true, script: 'jq -r .artifact_version metadata.json').trim()
                            println artifact_version
                            sh """
                           echo "${module}-${jobName} : ${artifact_version}" >> $JENKINS_HOME/summary/${envDir}/summary.txt
                            """
                        }
                    } else
                        println "This job can be only triggered from an upstream project."

                }
        stage('Archive artifacts') {
            sh "cp ${JENKINS_HOME}/summary/${envDir}/summary.txt ."
            archiveArtifacts artifacts: 'summary.txt', fingerprint: true, onlyIfSuccessful: true
        }
    }
    catch (err){
        throw err
    }
}
