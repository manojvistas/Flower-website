pipeline {
  agent any

  options {
    skipDefaultCheckout()
  }

  environment {
    EC2_USER = 'ubuntu'
    EC2_HOST = '13.201.38.173'     // update if your EC2 public IP changes
    WEBROOT  = '/var/www/html'
    FILES    = 'index.html styles.css script.js' // adjust if filenames differ
    SSH_CRED = 'ec2-ssh-key'       // Jenkins SSH credential id
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
        withCredentials([sshUserPrivateKey(credentialsId: env.SSH_CRED, keyFileVariable: 'SSH_KEY')]) {
          // run all commands in a single bat block so %SSH_KEY% expands correctly
          bat """
            echo === verify ssh/scp availability ===
            where ssh || (echo ssh not found && exit /b 1)
            where scp || (echo scp not found && exit /b 1)

            echo === Fix private key permissions (determine current account and set ACL) ===
            powershell -NoProfile -Command ^
              "$u=[System.Security.Principal.WindowsIdentity]::GetCurrent().Name; ^
               icacls('%SSH_KEY%') /inheritance:r | Out-Null; ^
               icacls('%SSH_KEY%') /grant:r (\"$u:F\") | Out-Null; ^
               Write-Output ('Set permissions on ' + '%SSH_KEY%' + ' for ' + $u)"

            echo === copy files to EC2 /tmp ===
            scp -o StrictHostKeyChecking=no -i "%SSH_KEY%" %FILES% %EC2_USER%@%EC2_HOST%:/tmp/

            echo === move files on EC2 and restart nginx ===
            ssh -o StrictHostKeyChecking=no -i "%SSH_KEY%" %EC2_USER%@%EC2_HOST% "sudo rm -f ${WEBROOT}/index.nginx-debian.html || true; sudo mv /tmp/index.html ${WEBROOT}/index.html || true; sudo mv /tmp/styles.css ${WEBROOT}/styles.css || true; sudo mv /tmp/script.js ${WEBROOT}/script.js || true; sudo chown -R www-data:www-data ${WEBROOT} || true; sudo systemctl restart nginx || true"

          """
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
