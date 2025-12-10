pipeline {
    agent any

    environment {
        PROJECT_ID        = 'REPLACE_WITH_YOUR_GCP_PROJECT_ID'   // e.g. my-static-project-123456
        REGION            = 'asia-south1'                        // change if you use another region
        REPO_NAME         = 'my-repo'                            // Artifact Registry repo name in GCP
        IMAGE_NAME        = 'flower-website'                     // Docker image name
        ARTIFACT_REGISTRY = "${REGION}-docker.pkg.dev"
        IMAGE_URI         = "${ARTIFACT_REGISTRY}/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:latest"
    }

    stages {
        stage('Checkout from GitHub') {
            steps {
                // Uses the same repo that you configured in Jenkins job
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${IMAGE_NAME}:latest"
                // Windows uses 'bat' instead of 'sh'
                bat "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Configure gcloud Docker Auth') {
            when {
                // skip this stage until you set a real PROJECT_ID
                expression { return env.PROJECT_ID != 'REPLACE_WITH_YOUR_GCP_PROJECT_ID' }
            }
            steps {
                echo "Configuring gcloud auth for ${ARTIFACT_REGISTRY}"
                bat "gcloud auth configure-docker ${ARTIFACT_REGISTRY} --quiet"
            }
        }

        stage('Tag & Push Image to Artifact Registry') {
            when {
                expression { return env.PROJECT_ID != 'REPLACE_WITH_YOUR_GCP_PROJECT_ID' }
            }
            steps {
                echo "Tagging image as ${IMAGE_URI}"
                bat "docker tag ${IMAGE_NAME}:latest ${IMAGE_URI}"

                echo "Pushing image to Artifact Registry"
                bat "docker push ${IMAGE_URI}"
            }
        }

        stage('Deploy to Kubernetes (optional)') {
            when {
                allOf {
                    expression { return env.PROJECT_ID != 'REPLACE_WITH_YOUR_GCP_PROJECT_ID' }
                    expression { return fileExists('k8s/deployment.yaml') }
                }
            }
            steps {
                echo "Deploying to Kubernetes from k8s/ manifests"
                bat "kubectl apply -f k8s"
            }
        }
    }
}


