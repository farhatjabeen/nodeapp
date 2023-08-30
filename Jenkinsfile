
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
         sh 'pm2 start npm app.js '
      }
    }  
    
  }
}
