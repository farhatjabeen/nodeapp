
pipeline {
  agent any
    
  tools {nodejs "node"}
    
  stages {
        
    stage('Git') {
      steps {
        git branch: 'main', changelog: false, credentialsId: 'My-git', poll: false, url: 'https://github.com/farhatjabeen/nodeapp.git'
      }
    }
     
    stage('Build') {
      steps {
        sh 'npm install'
        sh 'sudo docker build . -t nodeapp'
        sh 'docker tag nodeapp:latest 812422958103.dkr.ecr.ap-south-1.amazonaws.com/dockerrep:latest'
        sh 'docker push 812422958103.dkr.ecr.ap-south-1.amazonaws.com/dockerrep:latest'
         sh 'pm2 restart 0'
      }
    }  
    
  }
}
