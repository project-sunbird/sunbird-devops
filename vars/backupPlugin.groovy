// common plugin to clone code and build
def call(Map pipelineParams) {
pipeline {
        agent {
            node {
                label "${pipelineParams.agent}"
            }
        }
        stages {
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
