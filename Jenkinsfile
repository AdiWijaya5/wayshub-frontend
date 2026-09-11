def secret = 'key'
def server = 'jenkins@54.251.210.57'
def directory = 'wayshub-frontend'
def branch = 'master'
def images = 'adiwijayajy/wayshub-frontend:prod'
def container = 'wayshub-fe'

pipeline {
    agent any

    stages {
        stage('Pulling New Code') {
            steps {
                sshagent(credentials: ["${secret}"]) {
                    sh """ssh -o StrictHostKeyChecking=no ${server} << EOF
                    cd ${directory}
                    git pull origin ${branch}
                    exit
                    EOF"""
                }
            }
        }

        stage('Build Docker Image on Server') {
            steps {
                sshagent(credentials: ["${secret}"]) {
                    sh """ssh -o StrictHostKeyChecking=no ${server} << EOF
                    cd ${directory}
                    docker build -t ${images} .
                    exit
                    EOF"""
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USER')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push ${images}"
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                sshagent(credentials: ["${secret}"]) {
                    sh """ssh -o StrictHostKeyChecking=no ${server} << EOF
                    cd ${directory}
                    docker compose down
                    docker compose up -d
                    exit
                    EOF"""
                }
            }
        }
    }

    post {
	 success {
             withCredentials([string(credentialsId: 'discord-webhook-url', variable: 'DISCORD_URL')]) {
		 discordSend webhookURL: env.DISCORD_URL, result: 'SUCCESS', description: "Deployment berhasil!"
	     }
	 }
	 failure {
	     withCredentials([string(credentialsId: 'discord-webhook-url', variable: 'DISCORD_URL')]) {
		 discordSend webhookURL: env.DISCORD_URL, result: 'FAILURE', description: "Deployment gagal!"
	     }
	 }
}
