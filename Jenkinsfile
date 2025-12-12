pipeline {
  agent any

  options {
    skipDefaultCheckout()
  }

  environment {
    EC2_USER = 'ubuntu'
    EC2_HOST = '13.201.38.173'
    WEBROOT  = '/var/www/html'
    FILES    = 'index.html styles.css script.js'
    SSH_CRED = 'ec2-ssh-key'    // <-- update this to match your Jenkins credential id if different
  }

  stages {
    stage('Checkout (explicit, no changelog)') {
      steps {
        checkout([
          $class: 'GitSCM',
          branches: [[name: 'refs/heads/main']],
          doGenerateSubmoduleConfigurations: false,
          extensions: [],
          userRemoteConfigs: [[url: 'https://github.com/manojvistas/Flower-website.git']]
        ])
      }
    }

    stage('Deploy to EC2 (Windows agent using key file)') {
      steps {
        withCredentials([sshUserPrivateKey(credentialsId: "${SSH_CRED}", keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
          bat '''
echo === verify ssh/scp availability ===
where ssh || (echo ssh not found & exit /b 1)
where scp || (echo scp not found & exit /b 1)

echo === Fix private key ACLs ===
echo Key file: %SSH_KEY%
echo Running user: %COMPUTERNAME% %USERNAME%

icacls "%SSH_KEY%" /inheritance:r
icacls "%SSH_KEY%" /remove "BUILTIN\\Users" || echo remove ignored
icacls "%SSH_KEY%" /grant:r "%COMPUTERNAME%\\%USERNAME%:F" || echo grant user failed
icacls "%SSH_KEY%" /grant:r "NT AUTHORITY\\SYSTEM:(F)" || echo grant system failed
icacls "%SSH_KEY%" /grant:r "BUILTIN\\Administrators:(F)" || echo grant admin failed

echo === ACLs ===
icacls "%SSH_KEY%"

echo === copy files to EC2 /tmp ===
scp -o StrictHostKeyChecking=no -i "%SSH_KEY%" %FILES% %SSH_USER%@%EC2_HOST%:/tmp/

echo === deploy on EC2 ===
ssh -o StrictHostKeyChecking=no -i "%SSH_KEY%" %SSH_USER%@%EC2_HOST% "sudo cp -a ${WEBROOT} ${WEBROOT}_backup_%BUILD_ID% || true; sudo mv /tmp/index.html ${WEBROOT}/index.html || true; sudo mv /tmp/styles.css ${WEBROOT}/styles.css || true; sudo mv /tmp/script.js ${WEBROOT}/script.js || true; sudo chown -R www-data:www-data ${WEBROOT} || true; sudo systemctl restart nginx || true"
'''
        }
      }
    }
  }

  post {
    success {
      echo "Deployed successfully — visit: http://${env.EC2_HOST}"
    }
    failure {
      echo "Deployment failed — inspect console output for errors"
    }
  }
}
