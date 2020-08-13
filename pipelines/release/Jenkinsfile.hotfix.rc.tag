@Library('deploy-conf') _
node {
    try {
        repositories = ['Sunbird-Ed/SunbirdEd-portal',
                        'Sunbird-Ed/SunbirdEd-mobile',
                        'Sunbird-Ed/SunbirdEd-portal',
                        'Sunbird-Ed/SunbirdEd-mobile',
                        'project-sunbird/sunbird-lms-jobs',
                        'project-sunbird/sunbird-lms-service',
                        'project-sunbird/sunbird-data-pipeline',
                        'project-sunbird/sunbird-content-service'
                        ,'project-sunbird/sunbird-auth',
                        'project-sunbird/sunbird-learning-platform',
                        'project-sunbird/sunbird-content-plugins',
                        'project-sunbird/sunbird-lms-mw',
                        'project-sunbird/sunbird-ml-workbench',
                        'project-sunbird/sunbird-utils',
                        'project-sunbird/sunbird-analytics',
                        'project-sunbird/sunbird-telemetry-service',
                        'project-sunbird/secor',
                        'project-sunbird/sunbird-content-player',
                        'project-sunbird/sunbird-content-editor',
                        'project-sunbird/sunbird-content-plugins',
                        'project-sunbird/sunbird-collection-editor',
                        'project-sunbird/sunbird-generic-editor',
                        'project-sunbird/sunbird-devops']

        ansiColor('xterm') {
            String ANSI_GREEN = "\u001B[32m"
            String ANSI_NORMAL = "\u001B[0m"
            String ANSI_BOLD = "\u001B[1m"
            String ANSI_RED = "\u001B[31m"

            branch_name = params.release_branch
            if (branch_name.contains(env.public_repo_branch)) {
                println(ANSI_BOLD + ANSI_RED + "Error.. " + branch_name + " is not a hot fix branch "  + ANSI_NORMAL)
                error "Oh ho! branch is not a hofix branch.. Skipping creation of tag"
            }
            else {
                println (ANSI_BOLD + ANSI_GREEN + "All checks passed - Continuing build.." + ANSI_NORMAL)
            }


            if (params.size() == 0) {
                repoList = "['" + repositories.join("','") + "']"
                properties([[$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false], parameters([[$class: 'CascadeChoiceParameter', choiceType: 'PT_CHECKBOX', description: '<font color=black size=2><b>Choose the repo to create tag</b></font>', name: '', filterLength: 1, filterable: false, name: 'repositories', randomName: 'choice-parameter-2927218175384999', referencedParameters: '', script: [$class: 'GroovyScript', fallbackScript: [classpath: [], sandbox: false, script: ''], script: [classpath: [], sandbox: false, script: """return $repoList """]]], [$class: 'DynamicReferenceParameter', choiceType: 'ET_FORMATTED_HTML', description: '<font color=black size=2><b>Choose the branch from which tag will be created</b></font>', name: 'release_branch', omitValueField: true, randomName: 'choice-parameter-2927218195310673', referencedParameters: '', script: [$class: 'GroovyScript', fallbackScript: [classpath: [], sandbox: false, script: ''], script: [classpath: [], sandbox: false, script: 'return """<input name="value" value="${public_repo_branch}" class="setting-input"  type="text">"""']]]]), [$class: 'ThrottleJobProperty', categories: [], limitOneJobWithMatchingParams: false, maxConcurrentPerNode: 0, maxConcurrentTotal: 0, paramsToUseForLimit: '', throttleEnabled: false, throttleOption: 'project']])
                println(ANSI_BOLD + ANSI_GREEN + "First run of the job. Parameters created. Stopping the current build. Please trigger new build and provide parameters" + ANSI_NORMAL)
                return
            }

            if (!params.release_branch.contains('release-') || params.release_branch == '') {
                println(ANSI_BOLD + ANSI_RED + "Uh oh! Release branch is not in valid format. Please provide value as release-" + ANSI_NORMAL)
                error 'Error: Release branch name format error'
            }

            if(params.repositories == '')
            {
                print(ANSI_BOLD + ANSI_RED + "Uh oh! No repositories are selected!" + ANSI_NORMAL)
                error 'No repositories selected'
            }

            stage('Create tag') {
                sh """
                        mkdir -p ${JENKINS_HOME}/tags
                        touch -a ${JENKINS_HOME}/tags/tags.txt
                    """
                cleanWs()
                params.repositories.split(',').each { repo ->
                    dir("$WORKSPACE") {
                        repo_name = repo.split('/')[1]
                        sh "git clone --depth 1 --no-single-branch https://github.com/$repo $repo_name"
                        dir("$repo_name") {
                            returnCode = sh(returnStatus: true, script: "git ls-remote --exit-code --heads origin ${params.release_branch}")

                            if (returnCode != 0) {
                                println(ANSI_BOLD + ANSI_RED + params.release_branch + " branch does not exists" + ANSI_NORMAL)
                                error 'Error: Release branch does not exists'
                            }

                            withCredentials([usernamePassword(credentialsId: env.githubPassword, passwordVariable: 'gitpass', usernameVariable: 'gituser')]) {
                                origin = "https://${gituser}:${gitpass}@" + sh(script: 'git config --get remote.origin.url', returnStdout: true).trim().split('https://')[1]
                                echo "Git Hash: ${origin}"
                                tagRefBranch = sh(script: "git ls-remote --tags origin ${params.release_branch}* | grep -o ${params.release_branch}_RC.* | sort -V | tail -n1", returnStdout: true).trim()

                                if (tagRefBranch == '') {
                                    tagName = params.release_branch + '_RC1'
                                    sh("git push ${origin} refs/remotes/origin/${params.release_branch}:refs/tags/${tagName}")
                                }
                                else {
                                    returnCode = sh(script: "git diff --exit-code refs/remotes/origin/${params.release_branch} tags/$tagRefBranch > /dev/null", returnStatus: true)
                                    if (returnCode == 0) {
                                        println(ANSI_BOLD + ANSI_GREEN + "No commit changes found. Skipping creating tag" + ANSI_NORMAL)
                                        tagName = tagRefBranch
                                    }
                                    else {
                                        refCount = tagRefBranch.split('_RC')[-1].toInteger() + 1
                                        tagName = params.release_branch + '_RC' + refCount

                                        returnCode = sh(script: "git ls-remote --exit-code --tags ${origin} ${tagName}", returnStatus: true)

                                        if (returnCode == 0) {
                                            println(ANSI_BOLD + ANSI_RED + "Uh Oh! Remote has same tag name. Please check! This might have been created while build was running!" + ANSI_NORMAL)
                                            error 'Error: Stopping the build after finding same tag name. Please check'
                                        } else {
                                            sh("git push ${origin} refs/remotes/origin/${params.release_branch}:refs/tags/${tagName}")
                                        }
                                    }
                                }
                                sh """
                                      sed -i "s/${repo_name}.*//g" ${JENKINS_HOME}/tags/tags.txt
                                      sed -i "/^\\\$/d" ${JENKINS_HOME}/tags/tags.txt
                                      echo "$repo_name : $tagName" >> ${JENKINS_HOME}/tags/tags.txt
                                 """
                            }
                        }
                    }
                }
            }
            stage('Archive artifacts') {
                sh "cp ${JENKINS_HOME}/tags/tags.txt ."
                sh "sort tags.txt -o tags.txt && cat tags.txt"
                archiveArtifacts artifacts: 'tags.txt', fingerprint: true
            }
        }
    }

    catch (err) {
        currentBuild.result = 'FAILURE'
        throw err
    }    
    finally {
        slack_notify(currentBuild.result)
        email_notify()
    }
}
