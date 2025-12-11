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
        // Run container for a quick smoke-test on a random free host port, then clean up
        bat """
          for /f "delims=" %%p in ('powershell -NoProfile -Command "& { Get-Random -Minimum 20000 -Maximum 40000 }"') do set "HOST_PORT=%%p"
          docker run -d --name %IMAGE_NAME%_test -p %HOST_PORT%:8090 %IMAGE_NAME%:%IMAGE_TAG%
        """
        powershell '''
          $ErrorActionPreference = "Stop"
          $port = $env:HOST_PORT
          Start-Sleep -Seconds 5
          Invoke-WebRequest -UseBasicParsing ("http://localhost:{0}" -f $port) | Out-Null
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

