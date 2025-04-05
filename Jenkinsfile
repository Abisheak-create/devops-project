pipeline {
    agent any
    environment {
        IMAGE_NAME = "abisheak469/dev"
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'dev', url: 'https://github.com/Abisheak-create/devops-project.git'
            }
        }
        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'docker login -u "$DOCKER_USER" -p "$DOCKER_PASS"'
                }
            }
        }
        stage('Docker Compose Build') {
            steps {
                script {
                    sh 'docker-compose build'
                    sh "docker tag react_dev $IMAGE_NAME:$BUILD_NUMBER"
                }
            }
        }
        stage('Docker Push') {
            steps {
                script {
                    sh "docker push $IMAGE_NAME:$BUILD_NUMBER"
                }
            }
        }
        stage('Deploy with Docker Compose') {
            steps {
                script {
                    sh '''
                    docker-compose down || true  # Ignore error if no containers are running
                    docker ps -q --filter "publish=80" | xargs -r docker stop  # Stop any container using port 80
                    docker ps -a -q --filter "publish=80" | xargs -r docker rm  # Remove stopped container
                    docker-compose up -d
                    docker ps
                    '''
                    // Checking the webhook trigger
                }
            }
        }
    }
}
