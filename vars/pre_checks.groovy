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

            start = Date.parse("HH:mm:ss", env.START_TIME_STAGING)
            end = Date.parse("HH:mm:ss", env.END_TIME_STAGING)
            current = Date.parse("HH:mm:ss", current)

            if (current.after(start) && current.before(end)) {
                println ANSI_BOLD + ANSI_GREEN + "Tigger is in the deployment window.. Check if tag matches our pattern.." + ANSI_NORMAL
                tag_name = env.JOB_NAME.split("/")[-1]
                allowed_releases = env.staging_allowed_releases
                flag = 0

                // Temporary fix starts - For the creative branching strategy of Portal
/*                if (env.JOB_NAME.split("/")[-2] == "Player" && tag_name.contains(allowed_releases.split(",")[0])){
                    println ANSI_BOLD + ANSI_RED + "Block this build. Its creating unnecessry havoc.." + ANSI_NORMAL
                    error "This tag is blocked"
                } */
                // Temporary fix ends - For the creative branching strategy of Portal 
                
                for(i = 0; i < allowed_releases.split(",").length; i++) {
                    if (tag_name.contains(allowed_releases.split(",")[i]) && tag_name.contains("_RC")) {
                        println ANSI_BOLD + ANSI_GREEN + "All checks passed - Continuing build.." + ANSI_NORMAL
                        flag = 1
                        break;
                    }
                }
                if (flag == 0) {
                    println(ANSI_BOLD + ANSI_RED + "Error.. Tag does not contain " + env.automated_public_repo_branch + " or is not a RC tag" + ANSI_NORMAL)
                    error "Oh ho! Tag is not a release candidate.. Skipping build"
                }
            }
            else {
                println ANSI_BOLD + ANSI_RED + "Tigger is NOT in the deployment window. Skipping build" + ANSI_NORMAL
                error "Tigger is not in the deployment window. Skipping build"
            }
        }
    }
    catch (err){
        throw err
    }
}
