def call(String buildStatus, String release_tag=null, String jobName=null, int buildNumber=0, String jobUrl=null) {
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
                
                try {
                    if(env.automated_slack_channel != "" && release_tag != "") {
                        slackSend (
                                channel: env.automated_slack_channel,
                                color: slack_status,
                                message: "Build ${build_status} for ${release_tag} - Job Name: $JOB_NAME, Build Number: $BUILD_NUMBER, Click here for logs: (<${JOB_URL}|Open>)",
                                notifyCommitters: true,
                                baseUrl: env.automated_slack_workspace,
                                tokenCredentialId: 'automated_slack_token'
                        )
                        return
                    }

                    if(release_tag == null)
                    release_tag = "job"

                    envDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-3].trim()
                    channel_env_name = envDir.toUpperCase() + "_NOTIFY_SLACK_CHANNEL"
                    slack_channel = evaluate "$channel_env_name".replace('-', '')
                    slackSend(
                            channel: slack_channel,
                            color: slack_status,
                            message: "Build ${build_status} for ${release_tag} - Job Name: $JOB_NAME, Build Number: $BUILD_NUMBER, Click here for logs: (<${JOB_URL}|Open>)",
                    )
                    return
                }
                catch (MissingPropertyException ex) {
                    println ANSI_YELLOW + ANSI_BOLD + "Could not find env specific Slack channel. Check for global slack channel.." + ANSI_NORMAL
                }
                catch (ArrayIndexOutOfBoundsException ex) {
                    println ANSI_YELLOW + ANSI_BOLD + "Could not find env specific Slack channel. Check for global slack channel.." + ANSI_NORMAL
                }

                if(env.GLOBAL_NOTIFY_SLACK_CHANNEL != null)
                    if (release_tag != null && jobName != null && buildNumber != 0 && jobUrl != null)
                    {
                        slackSend(
                                channel: "${env.GLOBAL_NOTIFY_SLACK_CHANNEL}",
                                color: slack_status,
                                message: "Build ${build_status} for ${release_tag} - Job Name: $JOB_NAME, Build Number: $BUILD_NUMBER, Click here for logs: (<${JOB_URL}|Open>)",
                        )
                    }
                    else {
                        slackSend(
                                channel: "${env.GLOBAL_NOTIFY_SLACK_CHANNEL}",
                                color: slack_status,
                                message: "Build ${build_status} for ${release_tag} - Job Name: $JOB_NAME, Build Number: $BUILD_NUMBER, Click here for logs: (<${JOB_URL}|Open>)",
                        )
                    }
                else
                    println ANSI_YELLOW + ANSI_BOLD + "Could not find slack environment variable. Skipping slack notification.." + ANSI_NORMAL
            }
        }
    }
    catch (err){
        throw err
    }
}
