pipeline {
    agent any

    stages {
        stage('Pulling New Code') {
            // ... langkah-langkah ...
        }
        // ... stage lainnya ...
    } // <- Tutup kurung kurawal untuk 'stages'

    post {
        success {
            echo "Deployment berhasil!"
        }
        failure {
            echo "Deployment gagal!"
        }
    } // <- Tutup kurung kurawal untuk 'post'
}
