pipeline {
  agent any

  environment {
    EC2_USER = 'ubuntu'
    EC2_HOST = '13.201.38.173'    // update if IP changes
    WEBROOT  = '/var/www/html'
    FILES    = 'index.html styles.css script.js' // adjust if your files differ
    SSH_CRED = 'ec2-ssh-key'      // your Jenkins credential id
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Deploy to EC2 (Windows agent)') {
      steps {
        // Use sshagent to load the private key into an agent so ssh/scp can use it
        sshagent([env.SSH_CRED]) {
          // Ensure Windows OpenSSH client (ssh, scp) exists on the Jenkins agent
          bat '''
            echo === testing ssh/scp availability ===
            where ssh
            where scp
            echo === copying files to EC2 /tmp ===
            scp -o StrictHostKeyChecking=no %FILES% %EC2_USER%@%EC2_HOST%:/tmp/
            echo === moving files into webroot and restarting nginx ===
            ssh -o StrictHostKeyChecking=no %EC2_USER%@%EC2_HOST% "sudo rm -f ${WEBROOT}/index.nginx-debian.html || true; sudo mv /tmp/index.html ${WEBROOT}/index.html || true; sudo mv /tmp/styles.css ${WEBROOT}/styles.css || true; sudo mv /tmp/script.js ${WEBROOT}/script.js || true; sudo chown -R www-data:www-data ${WEBROOT}; sudo systemctl restart nginx"
          '''
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
