pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="812422958103"
        AWS_DEFAULT_REGION="ap-south-1"
        IMAGE_REPO_NAME="docker-py"
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
      steps{
        script {
          dockerImage = docker.build "${IMAGE_REPO_NAME}:${IMAGE_TAG}"
        }
      }
    }
   
    // Uploading Docker images into AWS ECR
    stage('Pushing to ECR') {
     steps{  
         script {
                sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:$IMAGE_TAG"
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
                    def messageText

                    if (buildStatus == 'SUCCESS') {
                        messageText = "<b>Test suite</b> = TEST CASE PASSED"
                                      
                    } else {
                        messageText = "<b>Test suite</b> = TEST CASE FAILED"
                                      
                    }

                    withCredentials([
                        string(credentialsId: 'telegramToken', variable: 'TOKEN'),
                        string(credentialsId: 'telegramChatid', variable: 'CHAT_ID')
                    ]) {
                        sh """
                            curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
                            -d "chat_id=${CHAT_ID}" \
                            -d "parse_mode=HTML" \
                            -d "text=${messageText}"
                        """
                    }
                }
            }
        }
    }
}
        
        
