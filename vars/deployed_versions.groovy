def call() {
    try {
        ansiColor('xterm') {
            String ANSI_GREEN = "\u001B[32m"
            String ANSI_NORMAL = "\u001B[0m"
            String ANSI_BOLD = "\u001B[1m"

            stage('check upstream') {
                values = [:]
                def upstream = currentBuild.rawBuild.getCause(hudson.model.Cause$UpstreamCause)
                triggerCause = upstream?.shortDescription
                if (triggerCause != null)
                    triggerCause = triggerCause.split()[4].replaceAll('"', '')
                values.put('absolute_job_path', triggerCause)
            }

            stage('Write data') {
                envDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-3].trim()
                if (values.absolute_job_path != null) {
                    module = values.absolute_job_path.split('/')[-2].toString().trim()
                    jobName = values.absolute_job_path.split('/')[-1].toString().trim()
                    println envDir + " " + module + " " + jobName

                    copyArtifacts projectName: values.absolute_job_path, fingerprintArtifacts: true, flatten: true, filter: 'metadata.json'
                    sh """
                        mkdir -p ${JENKINS_HOME}/summary/${envDir}
                        touch -a ${JENKINS_HOME}/summary/${envDir}/summary.txt
                    """

                    if (module == "Core") {
                        image_name = sh(returnStdout: true, script: 'jq -r .image_name metadata.json').trim()
                        image_tag = sh(returnStdout: true, script: 'jq -r .image_tag metadata.json').trim()
                        sh """
                            sed -i "s/${module}-${jobName}.*//g" ${JENKINS_HOME}/summary/${envDir}/summary.txt
                            sed -i "/^\\\$/d" ${JENKINS_HOME}/summary/${envDir}/summary.txt
                            echo "${module}-${jobName} : ${image_tag}" >> $JENKINS_HOME/summary/${envDir}/summary.txt
                        """
                    } else {
                        artifact_version = sh(returnStdout: true, script: 'jq -r .artifact_version metadata.json').trim()
                        sh """
                            sed -i "s/${module}-${jobName}.*//g" ${JENKINS_HOME}/summary/${envDir}/summary.txt
                            sed -i "/^\\\$/d" ${JENKINS_HOME}/summary/${envDir}/summary.txt
                            echo "${module}-${jobName} : ${artifact_version}" >> $JENKINS_HOME/summary/${envDir}/summary.txt
                        """
                    }
                } else
                    println(ANSI_BOLD + ANSI_GREEN + "This job can be only triggered from an upstream project." + ANSI_NORMAL)
            }

            stage('Archive artifacts') {
                sh "cp ${JENKINS_HOME}/summary/${envDir}/summary.txt ."
                sh "sort summary.txt -o summary.txt && cat summary.txt"
                archiveArtifacts artifacts: 'summary.txt', fingerprint: true, onlyIfSuccessful: true
                currentBuild.description = "${module}-${jobName}"

            }
        }
    }

    catch (err){
        throw err
    }
}
