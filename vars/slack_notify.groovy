def call() {
       try {
                stage('slack_notify') {
                     mainDir = sh(returnStdout: true, script: "echo $JOB_NAME").split('/')[-4].trim()
                     slack_channel = mainDir.toUpperCase() + "_NOTIFY_SLACK_CHANNEL"
                     if (slack_channel != null)
                      slackSend (
                         channel: slack_channel,
                         color: 'danger',
                         message: "Build Failed - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                      )
                        else if(env.GLOBAL_NOTIFY_SLACK_CHANNEL != null)
                         slackSend (
                            channel: "${env.GLOBAL_NOTIFY_SLACK_CHANNEL}",
                            color: 'danger',
                            message: "Build Failed - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                       )
                        else
                         println ANSI_YELLOW + ANSI_BOLD + "Could not find slack environment variable. Skipping slack notification.." + ANSI_NORMAL
      
            }
         }
      catch (err){
            throw err
        }
   }
