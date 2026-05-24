pipeline {
    agent any

    environment {
        APP_SERVER = '10.0.1.68'
        IMAGE_NAME = 'demo-project'
        CONTAINER_NAME = 'demo-app'
        APP_PORT = '8080'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Pulling latest code from GitHub...'
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh '''
                    cd app
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                    docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Deploy to App Server') {
            steps {
                echo 'Deploying to app server...'
                sh '''
                    docker save ${IMAGE_NAME}:latest | gzip > /tmp/${IMAGE_NAME}.tar.gz
                '''
                sshagent(['app-server-key']) {
                    sh '''
                        scp -o StrictHostKeyChecking=no /tmp/${IMAGE_NAME}.tar.gz ubuntu@${APP_SERVER}:/tmp/${IMAGE_NAME}.tar.gz
                        ssh -o StrictHostKeyChecking=no ubuntu@${APP_SERVER} "
                            docker load < /tmp/${IMAGE_NAME}.tar.gz
                            docker stop ${CONTAINER_NAME} || true
                            docker rm ${CONTAINER_NAME} || true
                            docker run -d \
                                --name ${CONTAINER_NAME} \
                                -p ${APP_PORT}:${APP_PORT} \
                                --restart always \
                                ${IMAGE_NAME}:latest
                        "
                    '''
                }
            }
        }

        stage('Health Check') {
            steps {
                echo 'Checking app health...'
                sh '''
                    sleep 5
                    curl -f http://${APP_SERVER}:${APP_PORT}/health || exit 1
                '''
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
