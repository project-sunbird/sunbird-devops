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
            current = Date.parse("HH:mm:ss", current)

            if (current.after(start) && current.before(end)) {
                println (ANSI_BOLD + ANSI_GREEN + "Tigger is in the deployment window.. Check if the release branch matches current release pattern.." + ANSI_NORMAL)
//                branch_name = params.release_branch
                if (params.release_branch != env.public_repo_branch) {
                    println(ANSI_BOLD + ANSI_RED + "Sorry.. The branch your entered does not match the release branch: " + env.public_repo_branch  + ANSI_NORMAL)
                    error "Oh ho! The branch your entered is not a staging release candidate.. Skipping creation of tag"
                }
                else {
                    println (ANSI_BOLD + ANSI_GREEN + "All checks passed - Continuing build.." + ANSI_NORMAL)
                }
            }
            else {
                println (ANSI_BOLD + ANSI_RED + "Tigger is NOT in the deployment window. Skipping build" + ANSI_NORMAL)
                error "Tigger is not in the deployment window. Skipping create tag"
            }
        }
    }
    catch (err){
        throw err
    }
}
