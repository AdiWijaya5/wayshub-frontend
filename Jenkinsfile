// ====================================================================
// 1. DEFINISI VARIABEL GLOBAL
// ====================================================================
def secret = 'aws-ec2-ssh'          
def discordSecret = 'discord-webhook-url' 
def dockerHubSecret = 'dockerhub-creds'   
def server = 'ubuntu@54.251.210.57' 
def directory = 'wayshub-frontend'
def branch = 'master'
def images = 'adiwijayajy/wayshub-frontend:prod' 
def container = 'wayshub-fe'

pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    sendDiscordNotification(discordSecret, "🔄 **CI/CD Started**\\nBuilding container **${container}** from branch **${branch}** (Build #${env.BUILD_NUMBER})", 3447003)
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

        // PERBAIKAN UTAMA: Proses pembersihan dipindahkan ke dalam Stage normal
        stage('Cleanup Workspace') {
            steps {
                echo "Cleaning up local build assets and workspace..."
                sh "docker rmi ${images} || true"
                cleanWs()
            }
        }
    }

    // ====================================================================
    // 2. BLOK POST-ACTIONS (Hanya Berisi Notifikasi Tanpa Perintah Shell Script)
    // ====================================================================
    post {
        success {
            script {
                try {
                    sendDiscordNotification(discordSecret, "✅ **CI/CD Success!**\\nContainer **${container}** successfully built, pushed to Docker Hub, and deployed to **${server}**!\\nURL: https://studentdumbways.my.id", 3066993)
                } catch (Exception e) {
                    echo "Gagal mengirim notifikasi sukses ke Discord: ${e.message}"
                }
            }
        }
        failure {
            script {
                try {
                    sendDiscordNotification(discordSecret, "❌ **CI/CD Failed!**\\nDeployment failed for container **${container}** (Build #${env.BUILD_NUMBER}).\\nSilakan periksa halaman Console Log Jenkins untuk melihat detail error.", 15158332)
                } catch (Exception e) {
                    echo "Gagal mengirim notifikasi gagal ke Discord: ${e.message}"
                }
            }
        }
    }
}

// ====================================================================
// 3. FUNGSI PEMBANTU (Helper Function) DISCORD NOTIFICATION
// ====================================================================
def sendDiscordNotification(String credentialId, String text, int colorCode) {
    withCredentials([string(credentialsId: credentialId, variable: 'DISCORD_WEBHOOK')]) {
        def jsonPayload = "{\"embeds\": [{\"title\": \"Jenkins CI/CD Alert\", \"description\": \"${text}\", \"color\": ${colorCode}}]}"
        echo "Mencoba mengirim notifikasi ke Discord..."
        sh "curl -v -sS -H 'Content-Type: application/json' -X POST -d '${jsonPayload}' \$DISCORD_WEBHOOK"
    }
}
