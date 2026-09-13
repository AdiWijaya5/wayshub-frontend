// ====================================================================
// 1. DEFINISI VARIABEL GLOBAL (User: jenkins)
// ====================================================================
def secret = 'aws-ec2-ssh'          
def discordSecret = 'discord-webhook-url' 
def dockerHubSecret = 'dockerhub-creds'   
def server = 'jenkins@54.251.210.57' // Menggunakan user jenkins Anda
def directory = 'wayshub-frontend'
def branch = 'master'
def images = 'adiwijayajy/wayshub-frontend:prod' 
def container = 'wayshub-fe'

pipeline {
    agent any

    stages {
        // Stage 1: Menghapus proteksi keamanan Git sebelum melakukan checkout
        stage('Fix Git Permission & Checkout') {
            steps {
                // Eksekusi izin Git global langsung di workspace server Jenkins
                sh "git config --global --add safe.directory /var/jenkins/workspace/dumbways-frotend"
                
                // Melakukan penarikan kode setelah konfigurasi aman disuntikkan
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

        stage('Push to Docker Hub') {
            steps {
                echo "Logging into Docker Hub and pushing image..."
                withCredentials([usernamePassword(credentialsId: dockerHubSecret, passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${images}"
                }
            }
        }

        stage('Deploy to AWS EC2 via Compose') {
            steps {
                echo "Deploying to server ${server} via Docker Compose..."
                sshagent(["${secret}"]) {
                    // Mentransfer file compose terbaru ke direktori server target
                    sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${server}:~/${directory}/docker-compose.yaml || true"
                    
                    sh """
                    ssh -o StrictHostKeyChecking=no ${server} '
                        cd ~/${directory}
                        docker compose pull
                        docker compose down || true
                        docker compose up -d
                        docker image prune -f
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

    // ====================================================================
    // 2. BLOK POST-ACTIONS GLOBAL (Dibungkus dengan node {} agar aman dari error)
    // ====================================================================
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
