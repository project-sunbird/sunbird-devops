def call() {
    try {
        ansiColor('xterm') {
            String ANSI_GREEN = "\u001B[32m"
            String ANSI_NORMAL = "\u001B[0m"
            String ANSI_BOLD = "\u001B[1m"
            String ANSI_RED = "\u001B[31m"
            String ANSI_YELLOW = "\u001B[33m"
            
//            if(buildStatus == "FAILURE")
//                currentBuild.result = "FAILURE"
//            else if(buildStatus == "SUCCESS")
//                currentBuild.result = "SUCCESS"
//            else
//                currentBuild.result = "UNSTABLE"

            stage('email_notify') {
                envDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-3].trim()
                email_group_name = envDir.toUpperCase() + "_EMAIL_GROUP"
                try {
                    email_group = evaluate "$email_group_name"
                    step([$class: 'Mailer',
                          notifyEveryUnstableBuild: true,
                          recipients: email_group,
                          sendToIndividuals: true])
                    return
                }
                catch (MissingPropertyException ex) {
                    println ANSI_YELLOW + ANSI_BOLD + "Could not find env specific email group. Check for global email group.." + ANSI_NORMAL
                }

                if(env.GLOBAL_EMAIL_GROUP != null)
                    step([$class: 'Mailer',
                          notifyEveryUnstableBuild: true,
                          recipients: "${env.GLOBAL_EMAIL_GROUP}",
                          sendToIndividuals: true])
                else
                    println ANSI_YELLOW + ANSI_BOLD + "Could not find global email group variable. Skipping email notification.." + ANSI_NORMAL
            }
        }
    }
    catch (err){
        throw err
    }
}
