def secret = 'aws-ec2-ssh'          
def discordSecret = 'discord-webhook-url' 
def dockerHubSecret = 'dockerhub-creds'   
def server = 'jenkins@54.251.210.57' 
def directory = 'wayshub-frontend'
def branch = 'main' 
def images = 'adiwijayajy/wayshub-frontend:prod' 
def container = 'wayshub-fe'

pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    sendDiscordNotification(discordSecret, "🔄 **CI/CD Started (STAGING)**\\nBuilding container via Docker Compose from branch **${branch}** (Build #${env.BUILD_NUMBER})", 3447003)
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
                script {
                    sendDiscordNotification(discordSecret, "📦 **Docker Hub Update!**\\nImage **${images}** successfully built and pushed to Docker Hub registry!", 16753920)
            }
            }
        }

    stage('Deploy to AWS EC2 via Compose') {
            steps {
                echo "Deploying to server ${server} via Docker Compose..."
                sshagent(["${secret}"]) {
                    sh "ssh -o StrictHostKeyChecking=no ${server} 'mkdir -p ~/${directory}'"
                    
                    sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${server}:~/${directory}/docker-compose.yaml"
                    
                    sh 'ssh -o StrictHostKeyChecking=no ' + server + ' "cd ~/' + directory + ' && docker compose pull && docker compose down || true && docker compose up -d && docker image prune -f"'
                }
            }
        }

        stage('Cleanup Workspace') {
            steps {
                echo "Cleaning up local build assets and workspace..."
                sh "docker rmi ${images} || true"
                cleanWs()
            }
        }
    }

    post {
        success {
            script {
                node {
                    try {
                        sendDiscordNotification(discordSecret, "✅ **CI/CD Success (STAGING)!**\\nContainer **${container}** successfully deployed via **Docker Compose** with tag `:stage`!\\nURL: https://studentdumbways.my.id", 3066993)
                    } catch (Exception e) {
                        echo "Gagal mengirim notifikasi sukses ke Discord: ${e.message}"
                    }
                }
            }
        }
        failure {
            script {
                node {
                    try {
                        sendDiscordNotification(discordSecret, "❌ **CI/CD Failed (STAGING)!**\\nDeployment via Docker Compose failed (Build #${env.BUILD_NUMBER}).\\nSilakan periksa halaman Console Log Jenkins.", 15158332)
                    } catch (Exception e) {
                        echo "Gagal mengirim notifikasi gagal ke Discord: ${e.message}"
                    }
                }
            }
        }
    }
}

