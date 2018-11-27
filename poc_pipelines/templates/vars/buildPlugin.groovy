// common plugin to clone code and build
def call(Map pipelineParams) {
pipeline {
        agent any
        stages {
            stage('checkout git') {
                steps {
                    git branch: pipelineParams.branch, url: pipelineParams.scmUrl
                }
            }

            stage('build') {
                steps {
                    sh 'ls'
                }
            }
        }
    }
}
