pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="812422958103"
        AWS_DEFAULT_REGION="ap-south-1"
        IMAGE_REPO_NAME="dockerrep"
        IMAGE_TAG="latest"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    }

    stages {
        stage('Logging into AWS ECR') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                }
            }
        }

        stage('Cloning Git') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'My-git', url: 'https://github.com/farhatjabeen/nodeapp.git']])     
            }
        }

        // Building Docker images
        stage('Building image') {
            steps {
                script {
                    dockerImage = docker.build "${IMAGE_REPO_NAME}:${IMAGE_TAG}"
                }
            }
        }

        // Uploading Docker images into AWS ECR
        stage('Pushing to ECR') {
            steps {
                script {
                    sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:${IMAGE_TAG}"
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Build') {
            steps {
            
                sh 'pm2 restart 0'
            }
        }

        stage('Push Notification') {
            steps {
                script {
                    def buildStatus = env.BUILD_STATUS ?: 'UNKNOWN'
                    def commitInfo = "Committed by: ${env.GIT_COMMIT_AUTHOR_NAME}"
                    def commitId = "Commit ID: ${env.GIT_COMMIT}"
                    def commitMsg = "Commit Message: ${env.GIT_COMMIT_MESSAGE}"
                    def messageText

                    if (buildStatus == 'FAILURE') {
                        messageText = "Jenkins job: nodeapp\n"
                        messageText += "Status: FAILURE\n"
                        messageText += "Committed by: ${commitInfo}\n"
                        messageText += "Commit ID: ${commitId}\n"
                        messageText += "Commit Message: ${commitMsg}"
                    } else {
                        messageText = "Jenkins job: nodeapp\n"
                        messageText += "Status: SUCCESS\n"
                        messageText += "Committed by: ${commitInfo}\n"
                        messageText += "Commit ID: ${commitId}\n"
                        
                    }

                    withCredentials([
                        string(credentialsId: 'telegramTocken', variable: 'TOKEN'),
                        string(credentialsId: 'telegramChatid', variable: 'CHAT_ID')
                    ]) {
                        sh """
                            curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
                            -d "chat_id=${CHAT_ID}" \
                            -d "text=${messageText}"
                        """
                    }
                }
            }
        }
    }
}
