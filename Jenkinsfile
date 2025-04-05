pipeline {
    agent any
    environment {
        DOCKER_HUB_USER = "abisheak469"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Set Image Name & Port') {
                script {
                    branchName = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                    if (branchName == "dev") {
                        imageName = "${DOCKER_HUB_USER}/dev"
                        port = "8081"
                    } else if (branchName == "master") {
                        imageName = "${DOCKER_HUB_USER}/prod"
                        port = "8082"
                    } else {
                        error("Unsupported branch: ${branchName}")
                    }
                    env.IMAGE_NAME = imageName
                    env.APP_PORT = port
                    echo "Branch: ${branchName}, Image: ${imageName}, Port: ${port}"
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
                    // triggering
                    sh """
                    docker-compose down || true
                    docker ps -q --filter "publish=$APP_PORT" | xargs -r docker stop
                    docker ps -a -q --filter "publish=$APP_PORT" | xargs -r docker rm
                    APP_PORT=$APP_PORT docker-compose up -d --build
                    docker ps
                    """
                }
            }
        }
    }
}
