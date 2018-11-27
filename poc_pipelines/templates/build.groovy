/**
 * Defines a build pipeline template (as a sample with one job parameter
 * that should be common for all pipelines)
 */
def createMyStandardDeclarativePipeline(Map templateParams) {

    pipeline {
        agent any
        parameters {
            string(name: 'myInput', description: 'Some pipeline parameters')
        }
        stages {
            stage('Stage one') {
                steps {
                    script {
                        echo "Parameter from template creation: " + templateParams.someParam
                    }
                }
            }
            stage('Stage two') {
                steps {
                    script {
                        echo "Job input parameter: " + params.myInput
                    }
                }
            }
        }
    }
}
