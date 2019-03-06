#!/usr/bin/groovy

/*
*
* This script will create a tag out of releaseBranch branch with name
* `<releaseBranch_RC{number}> specified in `releaseBranch` parameter variable.
* Checks for upstream branch with same name; then stops execution with and exception if same branch found in upstream.
*
* Parameters:
*   Name:   gitCredentialId
*      Type:   jenkins parameter; default value is githubPassword
*      Description:    contains github username and password for the user to be used
*   Name:   releaseBranch
*      Type:   jenkins parameter; default `public_repo_branch` variable
*      Description:    Name of the branch to create
*
* Author: Rajesh Rajendran<rjshrjndrn@gmail.com>
*
* This script uses curl and jq from the machine.
*
*/

node {
    // Creating color code strings
    String ANSI_GREEN = "\u001B[32m"
    String ANSI_NORMAL = "\u001B[0m"
    String ANSI_BOLD = "\u001B[1m"
    String ANSI_RED = "\u001B[31m"
    // Defining variables
    def gitCredentialId = params.gitCredentialId ?: 'githubPassword'
    def releaseBranch = params.releaseBranch ?: public_repo_branch
    try{

        // Checking first build and creating parameters
        if (params.size() == 0){
            properties([[$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false],
                        parameters([string(defaultValue: "${releaseBranch}",
                        description: '<font color=teal size=2>Release Branch create tag from</font>',
                        name: 'releaseBranch', trim: true)])])
            ansiColor('xterm') {
                println (ANSI_BOLD + ANSI_GREEN + '''\
                        First run of the job. Parameters created. Stopping the current build.
                        Please trigger new build and provide parameters if required.
                        '''.stripIndent().replace("\n"," ") + ANSI_NORMAL)
            }
        return
        }

        // Checking out public repo from where the branch should be created
        stage('Checking out branch'){
            // Cleaning workspace
            cleanWs()
            checkout scm
            ansiColor('xterm'){
                if( sh(
                script:  "git ls-remote --exit-code --heads origin ${params.releaseBranch}",
                returnStatus: true
                ) != 0) {
                    println(ANSI_BOLD + ANSI_RED + 'Release branch does not exist' + ANSI_NORMAL)
                    error 'Branch not exist'
                }
            }
        }
        stage('pushing tag to upstream'){
            // Using withCredentials as gitpublish plugin is not yet ported for pipelines
            // Defining credentialsId for default value passed from Parameter or environment value.
            // gitCredentialId is username and password type
            withCredentials([usernamePassword(credentialsId: "${gitCredentialId}",
            passwordVariable: 'gitPassword', usernameVariable: 'gitUser')]) {

                // Getting git remote url
                origin = "https://${gitUser}:${gitPassword}@"+sh (
                script: 'git config --get remote.origin.url',
                returnStdout: true
                ).trim().split('https://')[1]
                echo "Git Hash: ${origin}"

                /*
                 * Creating tagname
                 * Each tag should be of the naming convention `release<version>_RC<count>
                 * Count will increment as RC0 - for the first time, then RC1..n
                 */

                tagRefBranch = sh(
                    script: "git ls-remote --tags --sort='v:refname' origin | grep -o 'release-.*' | tail -n1",
                    returnStdout: true
                ).trim()
                if (tagRefBranch != ''){
                    tagName = releaseBranch+'_RC1'
                } else {
                    refCount = tagRefBranch.split('_RC')[-1].toInteger() + 1
                    tagName = releaseBranch + '_RC' + refCount
                }
                // Checks whether remtoe branch is present
                ansiColor('xterm'){
                    // If remote tag exists
                    if( sh(script: "git ls-remote --tags ${origin} ${params.releaseBranch}", returnStatus: true) == 0 ) {
                        println(ANSI_BOLD + ANSI_RED + "Upstream has tag with same name: ${tagName}" + ANSI_NORMAL)
                        error 'remote tag found with same name'
                    }
                }

                // Pushing tag
                sh("git push ${origin} heads/$releaseBranch:tags/${tagName}")
            }
        }
    }
    catch(org.jenkinsci.plugins.credentialsbinding.impl.CredentialNotFoundException e){
        ansiColor('xterm'){
            println(ANSI_BOLD + ANSI_RED + '''\
            either github credentialsId is not set or value is not correct. please set it as
            an environment variable. Derfault credentialsId name will be "githubPassword". The variable is supposed to contain a jenkins
            OcredentialsId which has github username, github password
            '''.stripIndent() + ANSI_NORMAL)
        error 'either gitCredentialId is not set or wrong value'
        }
    }
}
