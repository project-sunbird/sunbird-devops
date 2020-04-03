def call(){
    try {
        ansiColor('xterm') {
            String ANSI_GREEN = "\u001B[32m"
            String ANSI_NORMAL = "\u001B[0m"
            String ANSI_BOLD = "\u001B[1m"
            String ANSI_RED = "\u001B[31m"
            String ANSI_YELLOW = "\u001B[33m"
            
            tag_name = env.JOB_NAME.split("/")[-1]
            jobName = env.JOB_NAME.split("/")[-2]
            module = env.JOB_NAME.split("/")[-3]
            branch_or_tag = tag_name.split("_")[-0]
            envDir = "$auto_deploy_env"

            if (!jobName.contains("_RC")) {
                println("Error.. Tag does not contain RC")
                error("Oh ho! Tag is not a release candidate.. Skipping build")
            }
            println ANSI_BOLD + ANSI_GREEN + "$jobname build succeeded. Triggering ArtifactUpload.." + ANSI_NORMAL
            uploadStatus = build job: "ArtifactUpload/$envDir/$module/$jobName", parameters: [string(name: 'absolute_job_path', value: "$JOB_NAME")]
            if (uploadStatus.result == "SUCCESS") {
                println ANSI_BOLD + ANSI_GREEN + "ArtifactUpload/$envDir/$module/$jobName succeeded. Triggering Deployment.." + ANSI_NORMAL
                deployStatus = build job: "Deploy/$envDir/$module/$jobName", parameters: [string(name: 'private_branch', value: "$private_repo_branch"), string(name: 'branch_or_tag', value: "$branch_or_tag")]
                if (deployStatus.result == "SUCCESS") {
                    println ANSI_BOLD + ANSI_GREEN + "Deploy/$envDir/$module/$jobName succeeded. Notifying via email and slack.." + ANSI_NORMAL
                    slack_notify()
                    email_notify()
                } else {
                    println ANSI_BOLD + ANSI_RED + "Deploy/$envDir/$module/$jobName failed. Notifying via email and slack.." + ANSI_NORMAL
                    slack_notify()
                    email_notify()
                }
            } else {
                println ANSI_BOLD + ANSI_GREEN + "ArtifactUpload/$envDir/$module/$jobName failed. Notifying via email and slack.." + ANSI_NORMAL
                slack_notify()
                email_notify()
            }
        }
    }
    catch(err)
    {
        throw err
    }
}
