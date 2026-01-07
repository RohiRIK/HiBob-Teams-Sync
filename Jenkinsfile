pipeline {
    agent any

    parameters {
        choice(
            name: 'SCRIPT_LANGUAGE',
            choices: ['Node.js (npm)', 'PowerShell (Core)'],
            description: 'Select the runtime engine for the synchronization logic.'
        )
...
    stages {
        stage('Prepare Runtime') {
            steps {
                script {
                    if (params.SCRIPT_LANGUAGE == 'Node.js (npm)') {
                        echo "📦 Installing npm dependencies..."
                        sh 'npm install'
                    } else {
...
        stage('Execute Sync') {
            steps {
                script {
                    if (params.SCRIPT_LANGUAGE == 'Node.js (npm)') {
                        echo "⚡ Executing Node.js Logic..."
                        sh 'npm start'
                    } else {
    }

    post {
        always {
            echo "📝 Archiving execution logs..."
        }
    }
}
