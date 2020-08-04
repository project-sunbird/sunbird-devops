Skip to content
Search or jump to…

Pull requests
Issues
Marketplace
Explore

@keshavprasadms
        project-sunbird
/
sunbird-devops
11
30
127
Code
Issues
4
Pull requests
13
Actions
Projects
Wiki
Security
Insights
sunbird-devops/vars/stagingRC.groovy
@keshavprasadms
keshavprasadms feat: adding second time slot
Latest commit 641a4e6 41 seconds ago
History
2 contributors
@keshavprasadms@G33tha
42 lines (37 sloc)  1.91 KB

import java.text.SimpleDateFormat
def call() {
    try {
        ansiColor('xterm') {
            String ANSI_GREEN = "\u001B[32m"
            String ANSI_NORMAL = "\u001B[0m"
            String ANSI_BOLD = "\u001B[1m"
            String ANSI_RED = "\u001B[31m"
            String ANSI_YELLOW = "\u001B[33m"

            def date = new Date()
            def sdf = new SimpleDateFormat("HH:mm:ss")
            current = sdf.format(date)

            start = Date.parse("HH:mm:ss", env.START_TIME)
            end = Date.parse("HH:mm:ss", env.END_TIME)

            start1 = Date.parse("HH:mm:ss", env.START_TIME1)
            end1 = Date.parse("HH:mm:ss", env.END_TIME1)

            current = Date.parse("HH:mm:ss", current)

            if ((current.after(start) || current.after(start1)) && (current.before(end) || current.before(end1))) {
                println (ANSI_BOLD + ANSI_GREEN + "Tigger is in the deployment window.. Check if the branch entered matches the current release branch.." + ANSI_NORMAL)
                if (params.release_branch != env.public_repo_branch) {
                    println(ANSI_BOLD + ANSI_RED + "Oh Uh! The branch you entered does not match the staging release branch: " + env.public_repo_branch  + ANSI_NORMAL)
                    error "Oh ho! The branch your entered is not a staging release candidate.. Skipping creation of tag"
                }
                else {
                    println (ANSI_BOLD + ANSI_GREEN + "All checks passed - Continuing build.." + ANSI_NORMAL)
                }
            }
            else {
                println (ANSI_BOLD + ANSI_RED + "Tigger is NOT in the deployment window. Deployment windows are $env.START_TIME - $env.END_TIME and $env.START_TIME1 - $env.END_TIME1. Aborting!" + ANSI_NORMAL)
                error "Tigger is not in the deployment window. Aborted!"
            }
        }
    }
    catch (err){
        throw err
    }
}
