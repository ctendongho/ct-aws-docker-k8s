pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-2'
        IMAGE_NAME = 'ctendongho/ctdk8sinventorytracker'
        K8S_NAMESPACE = 'ct-aws-dk8s'
        K8S_DEPLOYMENT = 'ctdk8sinventorytracker'
        K8S_CONTAINER = 'ctdk8sinventorytracker'
        HELM_RELEASE = 'inventory'
    }

    stages {

        stage('Read Version') {
            steps {
                script {
                    env.IMAGE_TAG = sh(script: 'cat version.txt', returnStdout: true).trim()

                    echo "Branch: ${env.BRANCH_NAME}"
                    echo "Docker Image: ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    script {
                        def scannerHome = tool 'SonarScanner'

                        sh """
                        ${scannerHome}/bin/sonar-scanner \
                          -Dsonar.host.url=${SONAR_HOST_URL}
                        """
                    }
                }
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
                input message: 'Approve Terraform Apply?', ok: 'Apply'
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins'
                ]]) {
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

        stage('Trivy Scan') {
            steps {
                sh '''
                docker run --rm \
                  -v /var/run/docker.sock:/var/run/docker.sock \
                  aquasec/trivy:latest image \
                  --exit-code 1 \
                  --severity HIGH,CRITICAL \
                  --ignore-unfixed \
                  ${IMAGE_NAME}:${IMAGE_TAG}
                '''
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

        stage('Deploy to EKS with Helm') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins'
                ]]) {

                    sh '''
                    aws eks update-kubeconfig \
                      --region ${AWS_DEFAULT_REGION} \
                      --name ct-aws-dk8s-eks

                    helm upgrade --install ${HELM_RELEASE} helm/ctdk8sinventorytracker \
                      -n ${K8S_NAMESPACE} \
                      --create-namespace \
                      --set image.repository=${IMAGE_NAME} \
                      --set image.tag=${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Verify Rollout') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-jenkins'
                ]]) {

                    sh '''
                    aws eks update-kubeconfig \
                      --region ${AWS_DEFAULT_REGION} \
                      --name ct-aws-dk8s-eks

                    kubectl rollout status deployment/${K8S_DEPLOYMENT} \
                      -n ${K8S_NAMESPACE} \
                      --timeout=180s

                    kubectl get pods -n ${K8S_NAMESPACE}
                    '''
                }
            }
        }
    }
}         
