pipeline {
    agent any

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('myapp:v1')
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                sh '''
                    docker stop myapp-container || true
                    docker rm myapp-container || true
                    docker run -d -p 8090:8090 --name myapp-container myapp:v1
                '''
            }
        }

        stage('Deploy with Ansible') {
            steps {
                sh 'ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory deploy.yml'
            }
        }
    }
}
