pipeline {
    agent any
     environment {
            CI = 'true'
        }
    stages {
        stage('Build') {
            steps {
                sh 'npm install'
            }
        }
        stage('Test') {
                    steps {
                        sh 'node app.js'
                    }
                }
                stage('Deliver') {
                            steps {
                                sh 'pm2 start app'
                            }
                        }

    }
}
