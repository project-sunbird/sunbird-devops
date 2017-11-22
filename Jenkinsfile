pipeline {
    agent {
        label 'build-slave'
    }
    triggers {
        pollSCM('H/5 * * * *')
    }
    stages {
        stage('Pre-Build'){
            steps {
                sh('chmod a+x ansible/installDeps.sh')
                sh('./ansible/installDeps.sh')
            }
        }
        stage('Build') {
            steps {
                sh './test.sh'
            }
        }
    }
}