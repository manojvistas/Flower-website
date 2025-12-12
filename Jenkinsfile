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
    SSH_CRED = 'ec2-ssh-key'
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
    // replace 'ec2-deploy-key' with your credentials ID
    withCredentials([sshUserPrivateKey(credentialsId: 'ec2-deploy-key', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
      // Use a Windows bat block and a robust PowerShell call to set ACLs correctly
      bat """
      echo === verify ssh/scp availability ===
      where ssh || (echo ssh not found & exit /b 1)
      where scp || (echo scp not found & exit /b 1)

      echo === Fix private key permissions (determine current account and set ACL) ===
      powershell -NoProfile -Command ^
        $k = '${env.SSH_KEY}'; ^
        Write-Output \"Key path: $k\"; ^
        $u = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name; ^
        Write-Output \"Running as: $u\"; ^
        # remove inheritance on the file
        icacls $k /inheritance:r | Out-Null; ^
        # grant explicit full control to the current account (works even if name contains backslash)
        icacls $k /grant:r \"$u:(F)\" | Out-Null; ^
        # also grant SYSTEM just in case
        icacls $k /grant:r \"NT AUTHORITY\\SYSTEM:(F)\" | Out-Null; ^
        icacls $k

      echo === copy files to EC2 /tmp ===
      scp -o StrictHostKeyChecking=no -i "%SSH_KEY%" index.html styles.css script.js %SSH_USER%@13.201.38.173:/tmp/

      echo === move files on EC2 and restart nginx ===
      ssh -o StrictHostKeyChecking=no -i "%SSH_KEY%" %SSH_USER%@13.201.38.173 "sudo cp -a /var/www/html /var/www/html_backup_$(date +%F_%T) || true; sudo mv /tmp/index.html /var/www/html/index.html || true; sudo mv /tmp/styles.css /var/www/html/styles.css || true; sudo mv /tmp/script.js /var/www/html/script.js || true; sudo chown -R www-data:www-data /var/www/html || true; sudo systemctl restart nginx || true"
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
