pipeline {
    agent any

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('poc9')
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                sh '''
                    docker stop poc9-container || true
                    docker rm poc9-container || true
                    docker run -d -p 8090:8090 --name poc9-container poc9
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
