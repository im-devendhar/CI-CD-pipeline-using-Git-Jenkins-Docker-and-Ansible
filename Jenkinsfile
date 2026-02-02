pipeline {
    agent any

    environment {
        IMAGE_NAME = "devenops641/myapp:${BUILD_NUMBER}"
        LATEST_IMAGE = "devenops641/myapp:latest"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $IMAGE_NAME .
                docker tag $IMAGE_NAME $LATEST_IMAGE
                '''
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                    docker login -u $DOCKER_USER -p $DOCKER_PASS
                    docker push $IMAGE_NAME
                    docker push $LATEST_IMAGE
                    '''
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                sh '''
                ANSIBLE_HOST_KEY_CHECKING=False \
                ansible-playbook \
                -i inventory/aws_ec2.yml \
                -e image_tag=${BUILD_NUMBER} \
                deploy.yml
                '''
            }
        }
    }
}

