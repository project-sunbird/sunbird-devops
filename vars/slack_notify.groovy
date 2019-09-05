def call(String buildStatus) {
    try {
        ansiColor('xterm') {
            String ANSI_GREEN = "\u001B[32m"
            String ANSI_NORMAL = "\u001B[0m"
            String ANSI_BOLD = "\u001B[1m"
            String ANSI_RED = "\u001B[31m"
            String ANSI_YELLOW = "\u001B[33m"

            stage('slack_notify') {
                if(buildStatus == "FAILURE"){
                    slack_status = 'danger'
                    build_status = "Failed"
                }
                else {
                    slack_status = 'good'
                    build_status = "Succeded"
                }
                envDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-3].trim()
                channel_env_name = envDir.toUpperCase() + "_NOTIFY_SLACK_CHANNEL"
                try {
                    slack_channel = evaluate '$channel_env_name'
                    slackSend (
                            channel: slack_channel,
                            color: slack_status,
                            message: "Build ${build_status} - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                    )
                    return
                }
                catch (MissingPropertyException ex) {
                    println ANSI_YELLOW + ANSI_BOLD + "Could not find env specific Slack channel. Check for global slack channel.." + ANSI_NORMAL
                }

                if(env.GLOBAL_NOTIFY_SLACK_CHANNEL != null)
                    slackSend (
                            channel: "${env.GLOBAL_NOTIFY_SLACK_CHANNEL}",
                            color: slack_status,
                            message: "Build ${build_status} - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                    )
                else
                    println ANSI_YELLOW + ANSI_BOLD + "Could not find slack environment variable. Skipping slack notification.." + ANSI_NORMAL
            }
        }
    }
    catch (err){
        throw err
    }
}
