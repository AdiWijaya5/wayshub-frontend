def secret = 'aws-ec2-ssh'          
def discordSecret = 'discord-webhook-url' 
def dockerHubSecret = 'dockerhub-creds'   
def server = 'jenkins@54.251.210.57' 
def directory = 'wayshub-frontend'
def branch = 'master'
def images = 'adiwijayajy/wayshub-frontend:prod' 
def container = 'wayshub-fe'

pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // MENGGUNAKAN NATIVE SYNTAX (Menghilangkan pemicu error getUrl())
                checkout scm
                
                script {
                    sendDiscordNotification(discordSecret, "🔄 **CI/CD Started**\nBuilding container **${container}** from branch **${branch}** (Build #${env.BUILD_NUMBER})", 3447003)
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker Image: ${images}..."
                sh "docker build -t ${images} ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo "Logging into Docker Hub and pushing image..."
                withCredentials([usernamePassword(credentialsId: dockerHubSecret, passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${images}"
                }
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                echo "Deploying to server ${server} via SSH..."
                sshagent(["${secret}"]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${server} '
                        docker pull ${images}
                        docker stop ${container} || true
                        docker rm ${container} || true
                        docker run -d --name ${container} -p 3000:80 --restart always ${images}
                        docker image prune -f
                    '
                    """
                }
            }
        }
    }

    post {
        always {
            sh "docker rmi ${images} || true"
            cleanWs()
        }
        success {
            script {
                sendDiscordNotification(discordSecret, "✅ **CI/CD Success!**\nContainer **${container}** successfully built, pushed to Docker Hub, and deployed to **${server}**!\nURL: https://studentdumbways.my.id", 3066993)
            }
        }
        failure {
            script {
                sendDiscordNotification(discordSecret, "❌ **CI/CD Failed!**\nDeployment failed for container **${container}** (Build #${env.BUILD_NUMBER}). Check Jenkins console logs.", 15158332)
            }
        }
    }
}

// Fungsi pembantu kirim notifikasi ke Discord via curl
def sendDiscordNotification(String credentialId, String text, int colorCode) {
    withCredentials([string(credentialsId: credentialId, variable: 'DISCORD_WEBHOOK')]) {
        def jsonPayload = """{
            "embeds": [{
                "title": "Jenkins CI/CD Alert",
                "description": "${text}",
                "color": ${colorCode}
            }]
        }"""
        sh "curl -sS -i -H 'Content-Type: application/json' -X POST -d '${jsonPayload}' \$DISCORD_WEBHOOK"
    }
}
