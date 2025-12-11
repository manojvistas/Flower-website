pipeline {
  agent any
  environment {
    IMAGE = "myuser/flower-website:${env.BUILD_NUMBER}"
    DOCKER_CRED = 'dockerhub-creds'
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Build') {
      steps {
        script {
          docker.build("${IMAGE}")
        }
      }
    }
    stage('Push') {
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: env.DOCKER_CRED, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
            sh "docker push ${IMAGE}"
            sh "docker logout"
          }
        }
      }
    }
  }
  post {
    always { cleanWs() }
  }
}
