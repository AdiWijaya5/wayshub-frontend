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
    }
}
