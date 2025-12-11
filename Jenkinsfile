pipeline {
    agent any

    options {
        skipDefaultCheckout()
    }

    environment {
        EC2_USER = "ubuntu"
        EC2_HOST = "13.201.38.173"
        SSH_KEY_ID = "ec2-ssh-key"     // Jenkins credential ID
    }

    stages {

        stage('Checkout (explicit, no changelog)') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[url: 'https://github.com/manojvistas/Flower-website.git']]
                ])
            }
        }

        stage('Deploy to EC2 (Windows agent using key file)') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: "${SSH_KEY_ID}",
                                                   keyFileVariable: 'SSH_KEY')]) {

                    bat """
                        echo === verify ssh/scp availability ===
                        where ssh || (echo ssh not found && exit /b 1)
                        where scp || (echo scp not found && exit /b 1)

                        echo === Fix private key permissions ===
                        powershell -Command "icacls '%SSH_KEY%' /inheritance:r"
                        powershell -Command "icacls '%SSH_KEY%' /grant:r $env:USERNAME:F"

                        echo === copy files to EC2 /tmp ===
                        scp -o StrictHostKeyChecking=no -i "%SSH_KEY%" index.html styles.css script.js %EC2_USER%@%EC2_HOST%:/tmp/

                        echo === move files on EC2 and restart nginx ===
                        ssh -o StrictHostKeyChecking=no -i "%SSH_KEY%" %EC2_USER%@%EC2_HOST% "sudo rm -f /var/www/html/index.nginx-debian.html || true; sudo mv /tmp/index.html /var/www/html/index.html || true; sudo mv /tmp/styles.css /var/www/html/styles.css || true; sudo mv /tmp/script.js /var/www/html/script.js || true; sudo chown -R www-data:www-data /var/www/html || true; sudo systemctl restart nginx || true"
                    """
                }
            }
        }
    }

    post {
        failure {
            echo "Deployment failed — inspect console output for errors"
        }
    }
}
