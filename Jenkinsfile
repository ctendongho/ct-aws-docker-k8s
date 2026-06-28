pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    script {
                        def scannerHome = tool 'SonarScanner'
                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                          -Dsonar.host.url=$SONAR_HOST_URL
                        """
                    }
                }
            }
        }

        stage('Branch Check') {
            steps {
                sh 'echo "Running pipeline for branch: ${BRANCH_NAME}"'
            }
        }
    }
}
