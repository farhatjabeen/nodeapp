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
        
        stage('Push Notification') {
            steps {
                script {
                    def telegramMessage = ""
                    def isError = false

                    try {
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
      telegramMessage = "<b>Project</b> : node_app \\n" +
                                         "<b>Branch</b>: main \\n" +
                                         "<b>Build</b>: OK \\n" +
                                         "<b>Test suite</b> = TEST CASE PASSED"
                    } catch (Exception ex) {
                        // An error occurred in one of the pipeline stages
                        isError = true
                        def failedStage = env.STAGE_NAME ?: "Unknown Stage"
                        def errorMessage = ex.getMessage() ?: "Unknown Error"
                        telegramMessage = "<b>Project</b> : node_app \\n" +
                                         "<b>Branch</b>: main \\n" +
                                         "<b>Build</b>: ERROR \\n" +
                                         "<b>Test suite</b> = TEST CASE FAILED in stage: ${failedStage} \\n" +
                                         "<b>Error Message</b>: ${errorMessage}"
                    } finally {
                        // Print to verify values
                        echo "Telegram Message: ${telegramMessage}"
                        echo "T: ${T}"
                        echo "C: ${C}"

                        // Send the notification to Telegram
                        
                                withCredentials([string(credentialsId: 'telegramTocken', variable:'T'),
                                                  string(credentialsId: 'telegramChatid', variable:'C')]) {
                              sh """
                                 curl -s -X POST https://api.telegram.org/bot\${T}/sendMessage -d chat_id=\${C} -d parse_mode="HTML" -d text="${telegramMessage}"
                                  """
                        }
                    }

                    // Mark the build as failed if an error occurred
                    if (isError) {
                        currentBuild.result = "FAILURE"
                    } else {
                        currentBuild.result = "SUCCESS"
                    }
                }
            }
        }
    }
}
