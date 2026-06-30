pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-2'
        IMAGE_NAME = 'ctendongho/ctdk8sinventorytracker'
        K8S_NAMESPACE = 'ct-aws-dk8s'
        K8S_DEPLOYMENT = 'ctdk8sinventorytracker'
        K8S_CONTAINER = 'ctdk8sinventorytracker'
    }

    stages {
        stage('Read Version') {
            steps {
                script {
                    env.IMAGE_TAG = sh(script: 'cat version.txt', returnStdout: true).trim()
                    echo "Building branch: ${env.BRANCH_NAME}"
                    echo "Image: ${env.IMAGE_NAME}:${env.IMAGE_TAG}"
                }
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins']]) {
                    dir('terraform/environments/dev') {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins']]) {
                    dir('terraform/environments/dev') {
                        sh 'terraform validate'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins']]) {
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

        stage('Terraform Apply') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins']]) {
                    dir('terraform/environments/dev') {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} app'
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKERHUB_USER',
                    passwordVariable: 'DOCKERHUB_PASS'
                )]) {
                    sh '''
                    echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins']]) {
                    sh '''
                    aws eks update-kubeconfig --region ${AWS_DEFAULT_REGION} --name ct-aws-dk8s-eks

                    kubectl set image deployment/${K8S_DEPLOYMENT} \
                      ${K8S_CONTAINER}=${IMAGE_NAME}:${IMAGE_TAG} \
                      -n ${K8S_NAMESPACE}
                    '''
                }
            }
        }

        stage('Verify Rollout') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins']]) {
                    sh '''
                    aws eks update-kubeconfig --region ${AWS_DEFAULT_REGION} --name ct-aws-dk8s-eks
                    kubectl rollout status deployment/${K8S_DEPLOYMENT} -n ${K8S_NAMESPACE} --timeout=180s
                    kubectl get pods -n ${K8S_NAMESPACE}
                    '''
                }
            }
        }
    }
}

stage('Prepare Next Version') {
    steps {
        sh '''
        CURRENT_VERSION=$(cat version.txt)
        CURRENT_NUMBER=$(echo $CURRENT_VERSION | sed 's/v//')
        NEXT_NUMBER=$((CURRENT_NUMBER + 1))
        NEXT_VERSION="v${NEXT_NUMBER}"

        echo "$NEXT_VERSION" > version.txt

        git config user.name "jenkins"
        git config user.email "jenkins@local"
        git add version.txt
        git commit -m "Prepare next application version $NEXT_VERSION" || true
        git push origin dev
        '''
    }
}
