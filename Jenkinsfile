def secret = 'key'
def server = 'jenkins@54.251.210.57'
def directory = 'wayshub-fe'
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
            discordSend description: "Deployment menggunakan docker compose up -d untuk ${container} berhasil dilakukan ke server ${server}!",
                        result: 'SUCCESS',
                        webhookURL: "${env.DISCORD_WEBHOOK}",
                        title: 'Jenkins Deployment Success'
        }
        failure {
            discordSend description: "Deployment untuk ${container} gagal. Periksa kembali console output Jenkins.",
                        result: 'FAILURE',
                        webhookURL: "${env.DISCORD_WEBHOOK}",
                        title: 'Jenkins Deployment Failed'
        }
    }
}
