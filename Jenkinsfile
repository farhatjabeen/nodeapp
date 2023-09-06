pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="812422958103"
        AWS_DEFAULT_REGION="ap-south-1"
        IMAGE_REPO_NAME="dockerrep"
        IMAGE_TAG="latest"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        TELEGRAM_API_TOKEN = credentials('telegramTocken') // Use the ID of your credentials
        TELEGRAM_CHAT_ID = '1664009557'
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
        sh 'npm install'
         sh 'pm2 restart 0'
        }
      }  

    
    }
    post {
        success {
            script {
                def message = "Build Success! 🎉"
                sendTelegramMessage(message)
            }
        }

        failure {
            script {
                def message = "Build Failure! 😞"
                sendTelegramMessage(message)
            }
        }
    }
}

def sendTelegramMessage(String message) {
    def url = "https://api.telegram.org/bot${env.TELEGRAM_API_TOKEN}/sendMessage"
    def payload = [
        chat_id: env.TELEGRAM_CHAT_ID,
        text: message,
    ]

    def response = httpRequest(
        url: url,
        contentType: 'APPLICATION_JSON',
        httpMode: 'POST',
        requestBody: groovy.json.JsonOutput.toJson(payload)
    )

    if (response.status != 200) {
        error("Failed to send Telegram message. Status: ${response.status}, Response: ${response.content}")
    }
}
        
        
