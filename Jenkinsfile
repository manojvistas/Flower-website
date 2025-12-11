pipeline {
  agent any
  options {
    // Skip the implicit SCM checkout to avoid the deprecated git whatchanged call on Windows/git 2.52+
    skipDefaultCheckout()
  }
  environment {
    IMAGE_NAME = "flower-website"
    IMAGE_TAG  = "${env.BUILD_NUMBER}"
    REGISTRY   = "" // e.g. "asia-south1-docker.pkg.dev/YOUR_PROJECT_ID/my-repo"
    REG_CREDS  = "" // Jenkins credentials id for registry (optional)
  }
  stages {
    stage('Checkout') {
      steps {
        // Explicit checkout with changelog/poll disabled to dodge git whatchanged
        git changelog: false,
            poll: false,
            branch: 'main',
            url: 'https://github.com/manojvistas/Flower-website.git'
      }
    }

    stage('Build Docker Image') {
      steps {
        bat "docker build -t %IMAGE_NAME%:%IMAGE_TAG% ."
      }
    }

    stage('Run Tests (smoke)') {
      steps {
        // Stop and remove any existing container with same name
        bat "docker rm -f %IMAGE_NAME% 2>nul || true"
        // Run container on port 8095 for production use
        bat """
          docker run -d --name %IMAGE_NAME% -p 8095:8095 %IMAGE_NAME%:%IMAGE_TAG%
        """
        powershell '''
          $ErrorActionPreference = "Stop"
          Start-Sleep -Seconds 5
          Invoke-WebRequest -UseBasicParsing "http://localhost:8095" | Out-Null
        '''
        bat """
          docker logs %IMAGE_NAME%
        """
      }
    }

    stage('Push (optional)') {
      when {
        expression { return env.REGISTRY?.trim() }
      }
      steps {
        bat """
          docker login %REGISTRY% -u %REG_CREDS%
          docker tag %IMAGE_NAME%:%IMAGE_TAG% %REGISTRY%/%IMAGE_NAME%:%IMAGE_TAG%
          docker tag %IMAGE_NAME%:%IMAGE_TAG% %REGISTRY%/%IMAGE_NAME%:latest
          docker push %REGISTRY%/%IMAGE_NAME%:%IMAGE_TAG%
          docker push %REGISTRY%/%IMAGE_NAME%:latest
        """
      }
    }
  }

  post {
    always {
      bat 'docker image prune -f || true'
    }
    success {
      echo "Build and smoke test passed."
    }
    failure {
      echo "Build failed. Check logs."
    }
  }
}

