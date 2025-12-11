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
        // Explicit checkout with changelog disabled to avoid git whatchanged on Windows/git 2.52+
        checkout([
          $class: 'GitSCM',
          branches: [[name: '*/main']],
          userRemoteConfigs: [[url: 'https://github.com/manojvistas/Flower-website.git']],
          changelog: false,
          poll: false
        ])
      }
    }

    stage('Build Docker Image') {
      steps {
        bat "docker build -t %IMAGE_NAME%:%IMAGE_TAG% ."
      }
    }

    stage('Run Tests (smoke)') {
      steps {
        // Run container for a quick smoke-test, hit homepage, then clean up (Windows-friendly)
        bat """
          docker run -d --name %IMAGE_NAME%_test -p 8090:8090 %IMAGE_NAME%:%IMAGE_TAG%
          timeout /t 5 /nobreak >NUL
        """
        powershell '''
          $ErrorActionPreference = "Stop"
          Invoke-WebRequest -UseBasicParsing http://localhost:8090 | Out-Null
        '''
        bat """
          docker logs %IMAGE_NAME%_test
          docker rm -f %IMAGE_NAME%_test
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

