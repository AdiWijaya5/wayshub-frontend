def secret = 'key'
def server = 'jenkins@54.251.210.57'
def directory = 'wayshub-ferontend'
def branch = 'master'
def images = 'adiwijayajy/wayshub-frontend:prod'
def container = 'wayshub-fe'

pipeline {
    agent any
    stages {
        stage ('pulling new code'){
            steps{
                sshagent([secret]){
                    sh """ssh -o StrictHostKeyChecking=no ${server} << EOF 
                    cd ${directory}
                    git pull origin ${branch}
                    exit
                    EOF"""
                }
            }
        }
        stage ('Build Process'){
            steps{
                sshagent([secret]){
                    sh """ssh -o StrictHostKeyChecking=no ${server} << EOF 
                    cd ${directory}
                    docker build --no-cache -t ${image} .
                    exit
                    EOF"""
                }
            }
        }
        stage ('Deploy'){
            steps{
                sshagent([secret]){
                    sh """ssh -o StrictHostKeyChecking=no ${server} << EOF 
                    cd ${directory}
                    docker compose down
                    docker compose up -d
                    exit
                    EOF"""
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
}

