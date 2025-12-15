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
            where ssh
            where scp

            icacls "%SSH_KEY%" /inheritance:r
            icacls "%SSH_KEY%" /grant:r "%USERNAME%:F"

            scp -o StrictHostKeyChecking=no -i "%SSH_KEY%" ^
                index.html styles.css script.js ^
                ubuntu@13.201.38.173:/tmp/

            ssh -o StrictHostKeyChecking=no -i "%SSH_KEY%" ubuntu@13.201.38.173 ^
            "sudo mkdir -p /var/www/html && sudo cp -a /var/www/html /var/www/html_backup || true && sudo mv /tmp/index.html /var/www/html/index.html && sudo mv /tmp/styles.css /var/www/html/styles.css && sudo mv /tmp/script.js /var/www/html/script.js && sudo chown -R www-data:www-data /var/www/html && sudo systemctl restart nginx"
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
            echo "Deployment failed"
        }
    }
}
