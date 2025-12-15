pipeline {
    agent any

    environment {
        EC2_USER = "ubuntu"
        EC2_IP   = "13.201.38.173"
        WEBROOT  = "/var/www/html"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([
                    file(credentialsId: 'SSH_KEY_ID', variable: 'SSH_KEY')
                ]) {
                    bat """
                    echo ===== Verify SSH tools =====
                    where ssh
                    where scp

                    echo ===== Fix key permissions =====
                    icacls "%SSH_KEY%" /inheritance:r
                    icacls "%SSH_KEY%" /grant:r "%USERNAME%:F"

                    echo ===== Copy files to EC2 =====
                    scp -o StrictHostKeyChecking=no -i "%SSH_KEY%" ^
                        index.html styles.css script.js ^
                        %EC2_USER%@%EC2_IP%:/tmp/

                    echo ===== Deploy on EC2 =====
                    ssh -o StrictHostKeyChecking=no -i "%SSH_KEY%" %EC2_USER%@%EC2_IP% ^
                    "set -e;
                     sudo mkdir -p ${WEBROOT};
                     sudo cp -a ${WEBROOT} ${WEBROOT}_backup_\\$(date +%s) || true;
                     sudo mv /tmp/index.html ${WEBROOT}/index.html;
                     sudo mv /tmp/styles.css ${WEBROOT}/styles.css;
                     sudo mv /tmp/script.js ${WEBROOT}/script.js;
                     sudo chown -R www-data:www-data ${WEBROOT};
                     sudo systemctl restart nginx"
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Deployment successful — http://13.201.38.173"
        }
        failure {
            echo "Deployment failed — check logs"
        }
    }
}
