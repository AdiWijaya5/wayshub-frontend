def secret = 'aws-ec2-ssh'          // ID Kredensial SSH Key (.pem) di Jenkins UI
def discordSecret = 'discord-webhook-url' // ID Kredensial Secret Text Webhook Discord di Jenkins UI
def dockerHubSecret = 'dockerhub-creds'   // ID Kredensial Username/Password Docker Hub di Jenkins UI
def server = 'jenkins@54.251.210.57' // User SSH AWS EC2 (sesuaikan 'ubuntu' / 'ec2-user')
def directory = 'wayshub-frontend'
def branch = 'master'
def images = 'adiwijayajy/wayshub-frontend:prod' // Nama repositori Docker Hub Anda
def container = 'wayshub-fe'

pipeline {
    agent any

    stages {
        // Stage 1: Checkout Code menggunakan Native Syntax (Bebas Error getUrl)
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    sendDiscordNotification(discordSecret, "🔄 **CI/CD Started**\\nBuilding container **${container}** from branch **${branch}** (Build #${env.BUILD_NUMBER})", 3447003) // Warna Biru
                }
            }
        }

        // Stage 2: Build Image Lokal di Server Jenkins
        // (Pastikan Solusi Docker Sock di server Jenkins sudah diterapkan agar tidak error 'docker not found')
        stage('Build Docker Image') {
            steps {
                echo "Building Docker Image: ${images}..."
                sh "docker build -t ${images} ."
            }
        }

        // Stage 3: Login & Push Image ke Docker Hub
        stage('Push to Docker Hub') {
            steps {
                echo "Logging into Docker Hub and pushing image..."
                withCredentials([usernamePassword(credentialsId: dockerHubSecret, passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${images}"
                }
            }
        }

        // Stage 4: Remote SSH ke AWS EC2 untuk Deploy Container Baru
        stage('Deploy to AWS EC2') {
            steps {
                echo "Deploying to server ${server} via SSH..."
                sshagent(["${secret}"]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${server} '
                        # Tarik image terbaru yang barusan di-push ke Docker Hub
                        docker pull ${images}
                        
                        # Matikan dan hapus container lama jika sedang berjalan
                        docker stop ${container} || true
                        docker rm ${container} || true
                        
                        # Jalankan container baru di port 3000 (sesuai konfigurasi Nginx)
                        docker run -d --name ${container} -p 3000:80 --restart always ${images}
                        
                        # Bersihkan image usang agar penyimpanan AWS EC2 tidak penuh
                        docker image prune -f
                    '
                    """
                }
            }
        }
    }

    post {
        always {
            // Bersihkan image build lokal di server Jenkins dan kosongkan workspace
            sh "docker rmi ${images} || true"
            cleanWs()
        }
        success {
            script {
                try {
                    sendDiscordNotification(discordSecret, "✅ **CI/CD Success!**\\nContainer **${container}** successfully built, pushed to Docker Hub, and deployed to **${server}**!\\nURL: https://studentdumbways.my.id", 3066993) // Warna Hijau
                } catch (Exception e) {
                    echo "Gagal mengirim notifikasi sukses ke Discord: ${e.message}"
                }
            }
        }
        failure {
            script {
                try {
                    sendDiscordNotification(discordSecret, "❌ **CI/CD Failed!**\\nDeployment failed for container **${container}** (Build #${env.BUILD_NUMBER}).\\nSilakan periksa halaman Console Log Jenkins untuk melihat detail error.", 15158332) // Warna Merah
                } catch (Exception e) {
                    echo "Gagal mengirim notifikasi gagal ke Discord: ${e.message}"
                }
            }
        }
    }
}

def sendDiscordNotification(String credentialId, String text, int colorCode) {
    withCredentials([string(credentialsId: credentialId, variable: 'DISCORD_WEBHOOK')]) {
        // Payload JSON dibikin satu baris rapat agar aman dari masalah karakter ganti baris (escaping)
        def jsonPayload = "{\"embeds\": [{\"title\": \"Jenkins CI/CD Alert\", \"description\": \"${text}\", \"color\": ${colorCode}}]}"
        
        echo "Mencoba mengirim notifikasi ke Discord..."
        // Menggunakan flag '-v' (verbose) agar detail respons dari server Discord tercetak di Console Log Jenkins jika terjadi error
        sh "curl -v -sS -H 'Content-Type: application/json' -X POST -d '${jsonPayload}' \$DISCORD_WEBHOOK"
    }
}
