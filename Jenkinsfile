pipeline {
    agent any

    stages {
        stage('Branch Check') {
            steps {
                echo "Building branch: ${env.BRANCH_NAME}"
            }
        }

        stage('Terraform Version') {
            steps {
                sh 'terraform version'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('terraform') {
                    sh 'terraform validate'
                }
            }
        }
    }
}
