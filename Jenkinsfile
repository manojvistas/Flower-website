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
    SSH_CRED = 'ec2-ssh-key'    // <-- set this to your Jenkins credential ID
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
        // credentialsId uses the SSH_CRED environment variable
        withCredentials([sshUserPrivateKey(credentialsId: "${SSH_CRED}", keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
          // Literal bat block (triple-single-quoted) avoids Groovy interpolation of $ and ${}
          bat '''
echo === verify ssh/scp availability ===
where ssh || (echo ssh not found & exit /b 1)
where scp || (echo scp not found & exit /b 1)

echo === Fix private key permissions (determine current account and set ACL) ===
powershell -NoProfile -Command ^
  $k = '%SSH_KEY%'; ^
  $u = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name; ^
  Write-Output "Key path: $k"; ^
  Write-Output "Running as: $u"; ^
  # remove inheritance on the file
  icacls $k /inheritance:r | Out-Null; ^
  # grant explicit full control to the current account (handles backslash in account name)
  icacls $k /grant:r "$u:(F)" | Out-Null; ^
  # also grant SYSTEM just in case
  icacls $k /grant:r "NT AUTHORITY\\SYSTEM:(F)" | Out-Null; ^
  icacls $k

echo === copy files to EC2 /tmp ===
scp -o StrictHostKeyChecking=no -i "%SSH_KEY%" %FILES% %SSH_USER%@%EC2_HOST%:/tmp/

echo === move files on EC2 and restart nginx ===
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
