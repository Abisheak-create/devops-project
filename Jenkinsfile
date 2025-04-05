pipeline {
    agent any
    environment {
        IMAGE_NAME = ''
        APP_PORT = ''
    }
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Abisheak-create/devops-project.git'
            }
        }
        stage('Set Image Name & Port') {
            steps {
                script {
                    def branch = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                    if (branch == 'dev') {
                        env.IMAGE_NAME = "abisheak469/dev"
                        env.APP_PORT = "8081"
                    } else if (branch == 'master') {
                        env.IMAGE_NAME = "abisheak469/prod"
                        env.APP_PORT = "8082"
                    } else {
                        error("Unsupported branch: ${branch}")
                    }
                    echo "Branch: ${branch}, Image: ${env.IMAGE_NAME}, Port: ${env.APP_PORT}"
                }
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
