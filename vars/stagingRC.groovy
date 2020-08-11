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

            if ((current.after(start) && current.before(end)) || (current.after(start1) && current.before(end1))) {
                println (ANSI_BOLD + ANSI_GREEN + "Tigger is in the deployment window.. Check if the branch entered matches the current release branch.." + ANSI_NORMAL)
                allowed_releases = env.staging_allowed_releases
                flag = 0
                for(i = 0; i < allowed_releases.split(",").length; i++) {
                    if (params.release_branch == allowed_releases.split(",")[i]) {
                       println (ANSI_BOLD + ANSI_GREEN + "All checks passed - Continuing build.." + ANSI_NORMAL)
                       flag = 1
                       break;
                    }
                }
                if (flag == 0) {
                    println(ANSI_BOLD + ANSI_RED + "Oh Uh! The branch you entered does not match the staging release branch: " + env.public_repo_branch  + ANSI_NORMAL)
                    error "Oh ho! The branch your entered is not a staging release candidate.. Skipping creation of tag" 
                }
            }     
            else {
                println (ANSI_BOLD + ANSI_RED + "Tigger is NOT in the deployment window. Deployment windows are SLOT-1: $env.START_TIME - $env.END_TIME, SLOT-2: $env.START_TIME1 - $env.END_TIME1. Aborting!" + ANSI_NORMAL)
                error "Tigger is not in the deployment window. Aborted!"
            }
        }
    }
    catch (err){
        throw err
    }
}
