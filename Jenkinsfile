pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTION',
            choices: ['build','deploy','remove'],
            description: 'Pipeline action'
        )
    }

    environment {
        IMAGE_NAME   = "maitra2517/springboot-app"
        IMAGE_TAG    = "latest"
        DOCKER_CREDS = "dockerhub-creds"
    }

    stages {

        stage('Checkout') {
            when {
                expression { params.ACTION == 'build' || params.ACTION == 'deploy' }
            }
            steps {
                git branch: 'main',
                    url: 'https://github.com/Maitra-Biradar/ecommerce-m13-master.git'
            }
            post {
                success { echo 'Code checkout successful' }
                failure { echo 'Code checkout failed' }
                always  { echo 'Checkout stage completed' }
            }
        }

        stage('Build Docker Image') {
            when { expression { params.ACTION == 'build' } }
            steps {
                sh 'docker build --pull -t $IMAGE_NAME:$IMAGE_TAG .'
            }
            post {
                success { echo 'Docker image built successfully' }
                failure { echo 'Docker image build failed' }
                always  { echo 'Build Docker Image stage completed' }
            }
        }

        stage('Docker Login') {
            when { expression { params.ACTION == 'build' } }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                }
            }
            post {
                success { echo 'Docker login successful' }
                failure { echo 'Docker login failed' }
                always  { echo 'Docker Login stage completed' }
            }
        }

        stage('Docker Push') {
            when { expression { params.ACTION == 'build' } }
            steps {
                sh 'docker push $IMAGE_NAME:$IMAGE_TAG'
            }
            post {
                success { echo 'Docker image pushed to DockerHub' }
                failure { echo 'Docker image push failed' }
                always  { echo 'Docker Push stage completed' }
            }
        }

        stage('Docker Cleanup') {
            when { expression { params.ACTION == 'build' } }
            steps {
                sh '''
                  docker rmi $IMAGE_NAME:$IMAGE_TAG || true
                  docker logout
                '''
            }
            post {
                success { echo 'Docker cleanup completed' }
                failure { echo 'Docker cleanup encountered issues' }
                always  { echo 'Docker Cleanup stage completed' }
            }
        }

        stage('Deploy (docker-compose)') {
            when { expression { params.ACTION == 'deploy' } }
            steps {
                sh '''
                  docker-compose pull
                  docker-compose down || true
                  docker-compose up -d
                '''
            }
            post {
                success { echo 'Deployment successful on port 8085' }
                failure { echo 'Deployment failed' }
                always  { echo 'Deploy stage completed' }
            }
        }

        stage('Remove') {
            when { expression { params.ACTION == 'remove' } }
            steps {
                sh '''
                  docker-compose down
                  docker system prune -f
                '''
            }
            post {
                success { echo 'Application removed successfully' }
                failure { echo 'Remove operation failed' }
                always  { echo 'Remove stage completed' }
            }
        }
    }

    post {
        always  { echo 'Pipeline execution finished' }
        success { echo 'Pipeline completed successfully' }
        failure { echo 'Pipeline failed' }
    }
}
