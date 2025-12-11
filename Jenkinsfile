pipeline {
  agent any
  environment {
    IMAGE_NAME = "flower-website"
    IMAGE_TAG  = "${env.BUILD_NUMBER}"
    REGISTRY   = "" // e.g. "asia-south1-docker.pkg.dev/YOUR_PROJECT_ID/my-repo"
    REG_CREDS  = "" // Jenkins credentials id for registry (optional)
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          dockerImage = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
        }
      }
    }

    stage('Run Tests (smoke)') {
      steps {
        script {
          // Run container for a quick smoke-test, then curl it
          sh """
            docker run -d --name ${IMAGE_NAME}_test -p 8090:8090 ${IMAGE_NAME}:${IMAGE_TAG}
            sleep 2
            curl -f http://localhost:8090 || (docker logs ${IMAGE_NAME}_test && exit 1)
            docker rm -f ${IMAGE_NAME}_test
          """
        }
      }
    }

    stage('Push (optional)') {
      when {
        expression { return env.REGISTRY?.trim() }
      }
      steps {
        script {
          docker.withRegistry("https://${env.REGISTRY}", env.REG_CREDS) {
            dockerImage.push("${IMAGE_TAG}")
            dockerImage.push("latest")
          }
        }
      }
    }
  }

  post {
    always {
      sh 'docker image prune -f || true'
    }
    success {
      echo "Build and smoke test passed."
    }
    failure {
      echo "Build failed. Check logs."
    }
  }
}

