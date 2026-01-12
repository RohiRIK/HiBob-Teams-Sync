pipeline {
    agent any

    parameters {
        choice(
            name: 'SCRIPT_LANGUAGE',
            choices: ['TypeScript (Bun)', 'PowerShell (Core)'],
            description: 'Select the runtime engine for the synchronization logic.'
        )
...
    stages {
        stage('Prepare Runtime') {
            steps {
                script {
                    if (params.SCRIPT_LANGUAGE == 'TypeScript (Bun)') {
                        echo "📦 Installing Bun dependencies..."
                        sh 'bun install'
                    } else {
...
        stage('Execute Sync') {
            steps {
                script {
                    if (params.SCRIPT_LANGUAGE == 'TypeScript (Bun)') {
                        echo "⚡ Executing TypeScript Logic (Bun)..."
                        sh 'bun start'
                    } else {
    }

    post {
        always {
            echo "📝 Archiving execution logs..."
        }
    }
}
