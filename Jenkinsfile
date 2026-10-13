def secret = 'aws-ec2-ssh'          
def discordSecret = 'discord-webhook-url' 
def dockerHubSecret = 'dockerhub-creds'   
def server = '108.136.243.210'
def server_user = 'adi'
// def server = 'jenkins@54.251.210.57' // Menggunakan user SSH jenkins Anda
def directory = 'wayshub-frontend'
def branch = 'master'
def images = 'adiwijayajy/wayshub-frontend:latest' 
def container = 'wayshub-fe'

pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    sendDiscordNotification(discordSecret, "🔄 **CI/CD Started**\\nBuilding container via Docker Compose from branch **${branch}** (Build #${env.BUILD_NUMBER})", 3447003)
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker Image: ${images}..."
                sh "docker build -t ${images} ."
            }
        }

        stage('Security Scan (Trivy)') {
            steps {
                echo "Scanning Docker image for vulnerabilities using Trivy..."
                // Menggunakan Trivy untuk memindai image, exit-code 0 jika ingin melanjutkan atau 1 jika ingin menggagalkan build jika ada critical vulnerability
                sh "trivy image --severity HIGH,CRITICAL --exit-code 0 ${images}"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo "Logging into Docker Hub and pushing image..."
                withCredentials([string(credentialsId: dockerHubSecret, variable: 'DOCKER_PASS')]) {
                    sh "echo \$DOCKER_PASS | docker login -u adiwijayajy --password-stdin"
                    sh "docker push ${images}"
                }
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                echo "Deploying via SSH to AWS EC2..."
                sshagent(["${secret}"]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no adi@108.136.243.210 '
                            docker login -u adiwijayajy -p DOCKER_PASSWORD_ANDA &&
                            docker pull adiwijayajy/wayshub-frontend:latest &&
                            docker stop wayshub-fe || true &&
                            docker rm wayshub-fe || true &&
                            docker run -d --name wayshub-fe -p 3000:3000 adiwijayajy/wayshub-frontend:latest
                        '
                    """
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
                        sendDiscordNotification(discordSecret, "✅ **CI/CD Success!**\\nContainer successfully deployed via **Docker Compose** to **${server}**!\\nURL: https://studentdumbways.my.id", 3066993)
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
                        sendDiscordNotification(discordSecret, "❌ **CI/CD Failed!**\\nDeployment via Docker Compose failed (Build #${env.BUILD_NUMBER}).\\nSilakan periksa halaman Console Log Jenkins.", 15158332)
                    } catch (Exception e) {
                        echo "Gagal mengirim notifikasi gagal ke Discord: ${e.message}"
                    }
                }
            }
        }
    }
}

def sendDiscordNotification(String credentialId, String text, int colorCode) {
    withCredentials([string(credentialsId: credentialId, variable: 'DISCORD_WEBHOOK')]) {
        def jsonPayload = "{\"embeds\": [{\"title\": \"Jenkins CI/CD Alert\", \"description\": \"${text}\", \"color\": ${colorCode}}]}"
        echo "Mencoba mengirim notifikasi ke Discord..."
        sh "curl -v -sS -H 'Content-Type: application/json' -X POST -d '${jsonPayload}' \$DISCORD_WEBHOOK"
    }
}
