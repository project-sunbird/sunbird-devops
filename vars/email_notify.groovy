def call(String email_list = "") {
    try {
        ansiColor('xterm') {
            String ANSI_GREEN = "\u001B[32m"
            String ANSI_NORMAL = "\u001B[0m"
            String ANSI_BOLD = "\u001B[1m"
            String ANSI_RED = "\u001B[31m"
            String ANSI_YELLOW = "\u001B[33m"

           if(email_list.length() > 0){
                    emailext body: '''$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS: Check console output at $BUILD_URL to view the results.''', subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', to: email_list, attachLog: true, compressLog: true
                    return
           }
            stage('email_notify') {
                try {
                    envDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-3].trim()
                    email_group_name = envDir.toUpperCase() + "_EMAIL_GROUP"
                    email_group = evaluate "$email_group_name"
                    emailext body: '''$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS: Check console output at $BUILD_URL to view the results.''', subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', to: email_group
                    return
                }
                catch (MissingPropertyException ex) {
                    println ANSI_YELLOW + ANSI_BOLD + "Could not find env specific email group. Check for global email group.." + ANSI_NORMAL
                }
                catch (ArrayIndexOutOfBoundsException ex) {
                    println ANSI_YELLOW + ANSI_BOLD + "Could not find env specific email group. Check for global email group.." + ANSI_NORMAL
                }
                
                if(env.GLOBAL_EMAIL_GROUP != null)
                       emailext body: '''$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS: Check console output at $BUILD_URL to view the results.''', subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', to: env.GLOBAL_EMAIL_GROUP
                else
                    println ANSI_YELLOW + ANSI_BOLD + "Could not find global email group variable. Skipping email notification.." + ANSI_NORMAL
            }
        }
    }
    catch (err){
        throw err
    }
}
