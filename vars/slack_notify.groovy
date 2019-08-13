if(env.BACKUP_NOTIFY_SLACK_CHANNEL != null)
     slackSend (
            channel: "${env.BACKUP_NOTIFY_SLACK_CHANNEL}",
            color: 'danger',
            message: "Build Failed - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
        )
    else if(env.GLOBAL_NOTIFY_SLACK_CHANNEL != null)
     slackSend (
            channel: "${env.GLOBAL_NOTIFY_SLACK_CHANNEL}",
            color: 'danger',
            message: "Build Failed - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
        )
     code to send slack notification to this slack channel
    else
      println ANSI_YELLOW + ANSI_BOLD + "Could not find slack environment variable. Skipping slack notification.." + ANSI_NORMAL
