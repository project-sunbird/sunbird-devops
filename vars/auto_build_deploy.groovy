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
            envDir = "$auto_deploy_env"

            println ANSI_BOLD + ANSI_GREEN + "$jobName build succeeded. Triggering ArtifactUpload.." + ANSI_NORMAL

            uploadStatus = build job: "ArtifactUpload/$envDir/$module/$jobName", parameters: [string(name: 'absolute_job_path', value: "$JOB_NAME")]

            if (uploadStatus.currentResult == "SUCCESS") {
                println ANSI_BOLD + ANSI_GREEN + "ArtifactUpload/$envDir/$module/$jobName succeeded. Triggering Deployment.." + ANSI_NORMAL

//                slack_notify("SUCCESS", tag_name, uploadStatus.fullProjectName, uploadStatus.number, uploadStatus.absoluteUrl)
//                email_notify()

                if (module == "Core") {
                    module = "Kubernetes"
                }

                deployStatus = build job: "Deploy/$envDir/$module/$jobName", parameters: [string(name: 'private_branch', value: "$automated_private_repo_branch"), string(name: 'branch_or_tag', value: "$automated_public_repo_branch")]

                if (deployStatus.currentResult == "SUCCESS") {
                    println ANSI_BOLD + ANSI_GREEN + "Deploy/$envDir/$module/$jobName succeeded. Notifying via email and slack.." + ANSI_NORMAL

                    slack_notify("SUCCESS", tag_name, deployStatus.fullProjectName, deployStatus.number, deployStatus.absoluteUrl)
                    email_notify()
                    currentBuild.result = "SUCCESS"

                } else {
                    println ANSI_BOLD + ANSI_RED + "Deploy/$envDir/$module/$jobName failed. Notifying via email and slack.." + ANSI_NORMAL

                    slack_notify("FAILURE", tag_name, deployStatus.fullProjectName, deployStatus.number, deployStatus.absoluteUrl)
                    email_notify()
                    currentBuild.result = "UNSTABLE"

                }
            } else {
                println ANSI_BOLD + ANSI_GREEN + "ArtifactUpload/$envDir/$module/$jobName failed. Notifying via email and slack.." + ANSI_NORMAL

                slack_notify("FAILURE", tag_name, uploadStatus.fullProjectName, uploadStatus.number, uploadStatus.absoluteUrl)
                email_notify()
                currentBuild.result = "UNSTABLE"
            }
        }
    }
    catch(err)
    {
        throw err
    }
}
