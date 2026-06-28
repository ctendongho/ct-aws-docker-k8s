pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Building branch: ${env.BRANCH_NAME}"
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

        stage('Terraform Init') {
            when {
                anyOf {
                    branch 'dev'
                    branch 'main'
                }
            }
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            when {
                anyOf {
                    branch 'dev'
                    branch 'main'
                }
            }
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Manual Approval for Dev') {
            when {
                branch 'dev'
            }
            steps {
                input message: 'Terraform plan completed for dev. Do you want to apply?', ok: 'Apply'
            }
        }

        stage('Terraform Apply') {
            when {
                anyOf {
                    branch 'dev'
                    branch 'main'
                }
            }
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}
