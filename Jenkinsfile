pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-2'
    }

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
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins'
                ]]) {
                    dir('terraform/environments/dev') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins'
                ]]) {
                    dir('terraform/environments/dev') {
                        sh 'terraform validate'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins'
                ]]) {
                    dir('terraform/environments/dev') {
                        sh 'terraform plan -var-file=terraform.tfvars -out=tfplan'
                    }
                }
            }
        }

        stage('Manual Approval for Dev') {
            when {
                branch 'dev'
            }
            steps {
                input message: 'Approve Terraform apply for dev?', ok: 'Apply'
            }
        }
    }
}
