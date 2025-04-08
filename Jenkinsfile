pipeline {
    agent any

    environment {
        DEV_IMAGE = 'abisheak469/dev'
        PROD_IMAGE = 'abisheak469/prod'
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_USER = credentials('docker-hub-credentials').username
        DOCKER_PASS = credentials('docker-hub-credentials').password
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    def branch = env.GIT_BRANCH?.replaceFirst(/^origin\//, '') ?: 'dev'
                    echo "Checking out branch: ${branch}"
                    git branch: "${branch}", url: 'https://github.com/Abisheak-create/devops-project.git'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Running build.sh..."
                    chmod +x build.sh
                    ./build.sh
                '''
            }
        }

        stage('Deploy Application') {
            steps {
                sh '''
                    echo "Running deploy.sh..."
                    chmod +x deploy.sh
                    ./deploy.sh
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline finished"
        }
    }
}
