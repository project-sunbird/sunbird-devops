def call() {
       try {
            ansiColor('xterm') {
                String ANSI_GREEN = "\u001B[32m"
                String ANSI_NORMAL = "\u001B[0m"
                String ANSI_BOLD = "\u001B[1m"
                String ANSI_RED = "\u001B[31m"
                String ANSI_YELLOW = "\u001B[33m"
            
                stage('slack_notify') {
                     if(env.BUILD_NOTIFY_SLACK_CHANNEL != null)
                      slackSend (
                         channel: "${env.NOTIFY_SLACK_CHANNEL}",
                         color: 'danger',
                         message: "Build Failed - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                      )
                        else if(env.GLOBAL_NOTIFY_SLACK_CHANNEL != null)
                         slackSend (
                            channel: "${env.NOTIFY_SLACK_CHANNEL}",
                            color: 'danger',
                            message: "Build Failed - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                        else
                         println ANSI_YELLOW + ANSI_BOLD + "Could not find slack environment variable. Skipping slack notification.." + ANSI_NORMAL
      
            }
         }
      }
      catch (err){
            throw err
        }
   }
