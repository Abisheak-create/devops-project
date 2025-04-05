pipeline {
    agent any

    environment {
        DOCKERHUB_DEV = "abisheak469/dev"
        DOCKERHUB_PROD = "abisheak469/prod"
        PORT = ""
        IMAGE_NAME = ""
    }

    stages {
        stage('Init') {
            steps {
                script {
                    def branch = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()

                    if (branch == "dev") {
                        env.IMAGE_NAME = env.DOCKERHUB_DEV
                        env.PORT = "8081"
                        env.COMPOSE_FILE = "docker-compose.dev.yml"
                    } else if (branch == "master") {
                        env.IMAGE_NAME = env.DOCKERHUB_PROD
                        env.PORT = "8082"
                        env.COMPOSE_FILE = "docker-compose.prod.yml"
                    } else {
                        error("Unsupported branch: ${branch}")
                    }

                    echo "Branch: ${branch}"
                    echo "Image: ${env.IMAGE_NAME}:${BUILD_NUMBER}"
                    echo "Port: ${env.PORT}"
                }
            }
            }


        stage('Checkout') {
            steps {
                git url: 'https://github.com/Abisheak-create/devops-project.git', branch: "${env.BRANCH_NAME}"
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'docker login -u "$DOCKER_USER" -p "$DOCKER_PASS"'
                }
            }
        }

        stage('Docker Build & Tag') {
            steps {
                script {
                    sh "docker-compose -f ${COMPOSE_FILE} build"
                    sh "docker tag react-app ${IMAGE_NAME}:${BUILD_NUMBER}"
                }
            }
        }

        stage('Docker Push') {
            steps {
                sh "docker push ${IMAGE_NAME}:${BUILD_NUMBER}"
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh """
                    docker-compose -f ${COMPOSE_FILE} down || true
                    docker ps -q --filter "publish=${PORT}" | xargs -r docker stop
                    docker ps -a -q --filter "publish=${PORT}" | xargs -r docker rm
                    docker-compose -f ${COMPOSE_FILE} up -d
                    docker ps
                    """
                }
            }
        }
    }
}
