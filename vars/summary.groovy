def call() {
    try {
        ansiColor('xterm') {
            String ANSI_GREEN = "\u001B[32m"
            String ANSI_NORMAL = "\u001B[0m"
            String ANSI_BOLD = "\u001B[1m"


            jobName = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-1].trim()
            module = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-2].trim()
            envDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-3].trim()
            jobType = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-4].trim()
            privateBranch = params.private_branch
            publicBranch = params.branch_or_tag

            stage('Write data') {
                sh """
                    mkdir -p ${JENKINS_HOME}/summary/${envDir}
                    touch -a ${JENKINS_HOME}/summary/${envDir}/summary.txt
                """
                if (jobType == "Deploy") {
                    if (module == "Core" || module == "Kubernetes") {
                        image_tag = sh(returnStdout: true, script: 'if [ -f metadata.json ]; then jq -r .image_tag metadata.json; else echo "NA"; fi').trim()
                        sh """
                            #sed -i "s/${jobType}\\/${module}\\/${jobName}.*//g" ${JENKINS_HOME}/summary/${envDir}/summary.txt
                            #sed -i "/^\\\$/d" ${JENKINS_HOME}/summary/${envDir}/summary.txt
                            echo "${jobType}/${envDir}/${module}/${jobName},  imagetag: ${image_tag}, privatebranch: ${privateBranch}, publicbranch: ${publicBranch}">> $JENKINS_HOME/summary/${envDir}/summary.txt
                        """
                    } else {
                        artifact_version = sh(returnStdout: true, script: 'if [ -f metadata.json ]; then jq -r .artifact_version metadata.json; else echo "NA"; fi').trim()
                        sh """
                            #sed -i "s/${jobType}\\/${module}\\/${jobName}.*//g" ${JENKINS_HOME}/summary/${envDir}/summary.txt
                            #sed -i "/^\\\$/d" ${JENKINS_HOME}/summary/${envDir}/summary.txt
                            echo "${jobType}/${envDir}/${module}/${jobName},  artifact_version: ${artifact_version}, privatebranch: ${privateBranch}, publicbranch: ${publicBranch}" >> $JENKINS_HOME/summary/${envDir}/summary.txt
                        """
                    }
                }

                if (jobType == "Provision"  || jobType == "OpsAdministration") {
                    sh """
                        #sed -i "s/${jobType}\\/${module}\\/${jobName}.*//g" ${JENKINS_HOME}/summary/${envDir}/summary.txt
                        #sed -i "/^\\\$/d" ${JENKINS_HOME}/summary/${envDir}/summary.txt
                        echo "${jobType}/${envDir}/${module}/${jobName}, privatebranch: ${privateBranch}, publicbranch: ${publicBranch}" >> $JENKINS_HOME/summary/${envDir}/summary.txt
                    """
                }
            }
        }
    }

    catch (err){
        throw err
    }
}
