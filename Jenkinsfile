pipeline {
    agent any

    environment {
        DEV_IMAGE = 'abisheak469/dev'
        PROD_IMAGE = 'abisheak469/prod'
        IMAGE_TAG = "${BUILD_NUMBER}"
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

        stage('Docker Login') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'chmod +x build.sh'
                    sh './build.sh'
                }
            }
        }

        stage('Cleanup Existing Containers') {
            steps {
                script {
                    def port = env.BRANCH_NAME == 'dev' ? '8081' :
                               env.BRANCH_NAME == 'master' ? '8082' : ''
                    if (port) {
                        sh """
                            echo "Cleaning up containers running on port ${port}..."
                            CONTAINER_ID=\$(docker ps -q --filter "publish=${port}")
                            if [ ! -z "\$CONTAINER_ID" ]; then
                                docker stop \$CONTAINER_ID
                                docker rm \$CONTAINER_ID
                            fi
                        """
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh 'chmod +x deploy.sh'
                    sh './deploy.sh'
                }
            }
        }
    }
}
