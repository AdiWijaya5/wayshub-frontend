def Secret = 'aws-ec2-ssh'
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
                checkout([$class: 'GitSCM', 
                    branches: [[name: "refs/heads/${branch}"]], 
                    userRemoteConfigs: [[url: scm.getUserRemoteConfigs().getUrl()]]
                ])
                
                script {
                    sendDiscordNotification(discordSecret, "🔄 **CI/CD Started**\nBuilding container **${container}** from branch **${branch}** (Build #${env.BUILD_NUMBER})", 3447003) // Warna Biru
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker Image: ${images}..."
                // Melakukan build image lokal dengan tag sesuai variabel 'images'
                sh "docker build -t ${images} ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo "Logging into Docker Hub and pushing image..."
                // Menggunakan kredensial Docker Hub yang disimpan di Jenkins
                withCredentials([usernamePassword(credentialsId: dockerHubSecret, passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    // Login ke Docker Hub secara aman via stdin
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    
                    // Push image ke Docker Hub agar bisa ditarik oleh server AWS EC2
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
                        # Tarik image terbaru dari Docker Hub di dalam server target
                        docker pull ${images}
                        
                        # Matikan dan hapus container lama jika sedang berjalan
                        docker stop ${container} || true
                        docker rm ${container} || true
                        
                        # Jalankan container baru di port 3000 (sesuai konfigurasi Nginx)
                        docker run -d --name ${container} -p 3000:80 --restart always ${images}
                        
                        # Bersihkan image lama yang menggantung (dangling images)
                        docker image prune -f
                    '
                    """
                }
            }
        }
    }

    post {
        always {
            // Bersihkan image lokal di server Jenkins agar disk local tidak penuh
            sh "docker rmi ${images} || true"
            cleanWs()
        }
        success {
            script {
                sendDiscordNotification(discordSecret, "✅ **CI/CD Success!**\nContainer **${container}** successfully built, pushed to Docker Hub, and deployed to **${server}**!\nURL: https://studentdumbways.my.id", 3066993) // Warna Hijau
            }
        }
        failure {
            script {
                sendDiscordNotification(discordSecret, "❌ **CI/CD Failed!**\nDeployment failed for container **${container}** (Build #${env.BUILD_NUMBER}). Check Jenkins console logs.", 15158332) // Warna Merah
            }
        }
    }
}

// Fungsi pembantu untuk mengirim notifikasi ke Discord menggunakan curl
def sendDiscordNotification(String credentialId, String text, int colorCode) {
    withCredentials([string(credentialsId: credentialId, variable: 'DISCORD_WEBHOOK')]) {
        def jsonPayload = """
        {
            "embeds": [{
                "title": "Jenkins CI/CD Alert",
                "description": "${text}",
                "color": ${colorCode},
                "timestamp": "${new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(new java.util.Date())}"
            }]
        }
        """
        sh "curl -H 'Content-Type: application/json' -X POST -d '${jsonPayload}' \$DISCORD_WEBHOOK"
    }
}
