pipeline {
  agent any

  environment {
    EC2_USER = 'ubuntu'
    EC2_HOST = '13.201.38.173'     // your EC2 public IP
    WEBROOT  = '/var/www/html'
    FILES    = 'index.html styles.css script.js' // adjust if different
  }

  stages {
    stage('Checkout') {
      steps {
        // Use the same checkout you had
        checkout scm
      }
    }

    stage('Deploy to EC2 (Windows agent)') {
      steps {
        // This binds the SSH private key (credentials must be of type "SSH Username with private key")
        withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'SSH_KEY')]) {
          // Ensure Windows OpenSSH client is available on the Jenkins agent
          powershell """
            Write-Host "Using temporary key file: $env:SSH_KEY"
            Write-Host "Copying files to EC2 /tmp..."
            scp -o StrictHostKeyChecking=no -i "$env:SSH_KEY" ${FILES} ${EC2_USER}@${EC2_HOST}:/tmp/

            Write-Host "Moving files on EC2 and restarting nginx..."
            ssh -o StrictHostKeyChecking=no -i "$env:SSH_KEY" ${EC2_USER}@${EC2_HOST} `
              "sudo rm -f ${WEBROOT}/index.nginx-debian.html || true; \
               sudo mv /tmp/index.html ${WEBROOT}/index.html || true; \
               sudo mv /tmp/styles.css ${WEBROOT}/styles.css || true; \
               sudo mv /tmp/script.js ${WEBROOT}/script.js || true; \
               sudo chown -R www-data:www-data ${WEBROOT} || true; \
               sudo systemctl restart nginx || true"
          """
        }
      }
    }
  }

  post {
    success {
      echo "Deployed to http://${EC2_HOST}"
    }
    failure {
      echo "Deployment failed — check console output"
    }
  }
}
