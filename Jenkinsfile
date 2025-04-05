pipeline {
    agent any

    environment {
        DOCKERHUB_DEV = "abisheak469/dev"
        DOCKERHUB_PROD = "abisheak469/prod"
        BRANCH = "${env.BRANCH_NAME}"
    }

    stages {
        stage('Init') {
            steps {
                script {
                    if (BRANCH == "dev") {
                        IMAGE_NAME = "${DOCKERHUB_DEV}"
                        PORT = "8081"
                        COMPOSE_FILE = "docker-compose.dev.yml"
                    } else if (BRANCH == "master") {
                        IMAGE_NAME = "${DOCKERHUB_PROD}"
                        PORT = "8082"
                        COMPOSE_FILE = "docker-compose.prod.yml"
                    } else {
                        error("Unsupported branch: ${BRANCH}")
                    }

                    // Export as env vars for later stages
                    env.IMAGE_NAME = IMAGE_NAME
                    env.PORT = PORT
                    env.COMPOSE_FILE = COMPOSE_FILE

                    echo "Branch: ${BRANCH}"
                    echo "Using image: ${env.IMAGE_NAME}:${BUILD_NUMBER}"
                    echo "Using port: ${env.PORT}"
                    echo "Compose file: ${env.COMPOSE_FILE}"
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

        stage('Docker Build & Push') {
            steps {
                script {
                    sh "docker build -t ${env.IMAGE_NAME}:${BUILD_NUMBER} ."
                    sh "docker push ${env.IMAGE_NAME}:${BUILD_NUMBER}"
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh """
                    docker-compose -f ${env.COMPOSE_FILE} down || true
                    docker ps -q --filter "publish=${env.PORT}" | xargs -r docker stop
                    docker ps -a -q --filter "publish=${env.PORT}" | xargs -r docker rm
                    docker-compose -f ${env.COMPOSE_FILE} up -d
                    docker ps
                    """
                }
            }
        }
    }
}
