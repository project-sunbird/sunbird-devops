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
                    if(env.automated_slack_channel != "" && release_tag != null) {
                        if (jobName == null)
                            jobName = env.JOB_NAME
                        if (buildNumber == 0)
                            buildNumber = env.BUILD_NUMBER
                        if (jobUrl == null)
                            jobUrl = env.JOB_URL

                        slackSend (
                                channel: env.automated_slack_channel,
                                color: slack_status,
                                message: "$jobName - ${release_tag}, #$buildNumber, Logs: (<${jobUrl}|Open>)",
                                baseUrl: env.automated_slack_workspace,
                                tokenCredentialId: 'automated_slack_token'
                        )
                        return
                    }

                    if((release_tag == null || release_tag == "") && params.github_release_tag != null && params.github_release_tag != "") {
                        release_tag = params.github_release_tag
                    }
                    else {
                        folder = new File("$WORKSPACE/.git")
                        if (folder.exists()) {
                            commit_hash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                            branch_name = sh(script: 'git name-rev --name-only HEAD | rev | cut -d "/" -f1| rev', returnStdout: true).trim()
                            release_tag = branch_name + "_" + commit_hash
                        }
                        else
                            release_tag = jobName
                    }

                    envDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-3].trim()
                    channel_env_name = envDir.toUpperCase() + "_NOTIFY_SLACK_CHANNEL"
                    slack_channel = evaluate "$channel_env_name".replace('-', '')
                    slackSend(
                            channel: slack_channel,
                            color: slack_status,
                            message: "$jobName - ${release_tag}, #$buildNumber, Logs: (<${jobUrl}|Open>)",
                    )
                    return
                }
                catch (MissingPropertyException ex) {
                    println ANSI_YELLOW + ANSI_BOLD + "Could not find env specific Slack channel. Check for global slack channel.." + ANSI_NORMAL
                }
                catch (ArrayIndexOutOfBoundsException ex) {
                    println ANSI_YELLOW + ANSI_BOLD + "Could not find env specific Slack channel. Check for global slack channel.." + ANSI_NORMAL
                }

                if(env.GLOBAL_NOTIFY_SLACK_CHANNEL != null) {
                    slackSend(
                            channel: "${env.GLOBAL_NOTIFY_SLACK_CHANNEL}",
                            color: slack_status,
                            message: "$jobName - ${release_tag}, #$buildNumber, Logs: (<${jobUrl}|Open>)",
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
