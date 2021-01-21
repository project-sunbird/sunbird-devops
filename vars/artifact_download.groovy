def call(Map values) {
    try {
        ansiColor('xterm') {
            String ANSI_GREEN = "\u001B[32m"
            String ANSI_NORMAL = "\u001B[0m"
            String ANSI_BOLD = "\u001B[1m"
            String ANSI_RED = "\u001B[31m"
            String ANSI_YELLOW = "\u001B[33m"

            if (params.artifact_source == "ArtifactRepo" || values.ignore_job_parameter == true) {
                println(ANSI_BOLD + ANSI_YELLOW + "Option chosen is ArtifactRepo or ignore_job_parameter is set - Downloading artifacts from remote source" + ANSI_NORMAL)
                ansiblePlaybook = "${values.currentWs}/ansible/artifacts-download.yml"
                ansibleExtraArgs = "--extra-vars \"artifact=${values.artifact} artifact_path=${values.currentWs}/${values.artifact}\" --vault-password-file /var/lib/jenkins/secrets/vault-pass"
                values.put('ansiblePlaybook', ansiblePlaybook)
                values.put('ansibleExtraArgs', ansibleExtraArgs)
                ansible_playbook_run(values)
            }
            else {
                println(ANSI_BOLD + ANSI_YELLOW + "Option chosen is JenkinsJob, using the artifacts copied" + ANSI_NORMAL)
            }
        }
    }
    catch (err) {
        throw err
    }
}
