pipeline {
    agent any

    // ====== EDIT THESE VALUES LATER ======
    environment {
        PROJECT_ID        = 'REPLACE_WITH_YOUR_GCP_PROJECT_ID'   // e.g. my-static-project-123456
        REGION            = 'asia-south1'                        // you can change if you use another region
        REPO_NAME         = 'my-repo'                            // Artifact Registry repo name (you will create in GCP)
        IMAGE_NAME        = 'flower-website'                     // Docker image name
        ARTIFACT_REGISTRY = "${REGION}-docker.pkg.dev"
        IMAGE_URI         = "${ARTIFACT_REGISTRY}/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:latest"
    }

    stages {
        stage('Checkout from GitHub') {
            steps {
                // This works when you configure "Pipeline script from SCM" in Jenkins
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${IMAGE_NAME}:latest"
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Configure gcloud Docker Auth') {
            steps {
                echo "Configuring gcloud auth for ${ARTIFACT_REGISTRY}"
                sh "gcloud auth configure-docker ${ARTIFACT_REGISTRY} --quiet"
            }
        }

        stage('Tag & Push Image to Artifact Registry') {
            steps {
                echo "Tagging image as ${IMAGE_URI}"
                sh "docker tag ${IMAGE_NAME}:latest ${IMAGE_URI}"

                echo "Pushing image to Artifact Registry"
                sh "docker push ${IMAGE_URI}"
            }
        }

        stage('Deploy to Kubernetes (optional)') {
            when {
                // This will run only if you create a k8s/ folder with YAML files
                expression { return fileExists('k8s/deployment.yaml') }
            }
            steps {
                echo "Deploying to Kubernetes from k8s/ manifests"
                sh "kubectl apply -f k8s/"
            }
        }
    }
}

