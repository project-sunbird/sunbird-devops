// common plugin to clone code and build
def call(Map pipelineParams) {
def installDeps = libraryResource 'installDeps.sh'
pipeline {
        agent {
            node {
                label "${pipelineParams.agent}"
            }
        }
        stages {
            // installing deps
            stage('installing deps'){
                sh installDeps
            }

            // cloning public sunbird-devops
            stage('checkout git') {
                steps {
                    dir('sunbird-devops'){
                    git branch: pipelineParams.branch, url: pipelineParams.scmUrl
                    }
                }
            }

            stage('Backup') {
                steps {
                    script{
                        sh 'ls'
                        sh """
                        ansible-playbook -i ansible/inventories/${pipelineParams.env} sunbird-devops/ansible/${pipelineParams.playBook} ${pipelineParams.ansibleExtraArgs}
                        """
                    }
                }
            }
        }
    }
}
