pipeline {
    agent any

    parameters {
        choice(
            name: 'SCRIPT_LANGUAGE',
            choices: ['TypeScript (Bun)', 'PowerShell (Core)'],
            description: 'Select the runtime engine for the synchronization logic.'
        )
        booleanParam(
            name: 'SYNC_AVATARS',
            defaultValue: true,
            description: 'Enable synchronization of HiBob profile pictures to Microsoft Teams.'
        )
        string(
            name: 'TEST_USER_EMAIL',
            defaultValue: '',
            description: 'Optional: Enter a specific email to test the sync on a single user. Leave empty for full sync.'
        )
        booleanParam(
            name: 'DRY_RUN',
            defaultValue: true,
            description: 'Safe Mode: If checked, logs intended changes without applying them.'
        )
    }

    environment {
        // Secrets injected from Jenkins Credentials Store
        HIBOB_TOKEN         = credentials('hibob-api-token')
        AZURE_CLIENT_ID     = credentials('azure-app-client-id')
        AZURE_CLIENT_SECRET = credentials('azure-app-client-secret')
        AZURE_TENANT_ID     = credentials('azure-tenant-id')
        
        // Configuration
        IS_DRY_RUN          = "${params.DRY_RUN}"
        DO_SYNC_AVATARS     = "${params.SYNC_AVATARS}"
        TEST_USER_EMAIL     = "${params.TEST_USER_EMAIL}"
    }

    stages {
        stage('Initialization') {
            steps {
                script {
                    echo "Mode: ${params.DRY_RUN ? 'DRY RUN' : 'LIVE'}"
                    if (params.TEST_USER_EMAIL) {
                        echo "🎯 Targeted Test Mode: Syncing ONLY ${params.TEST_USER_EMAIL}"
                    }
                }
            }
        }

        stage('Prepare Runtime') {
            steps {
                script {
                    if (params.SCRIPT_LANGUAGE == 'TypeScript (Bun)') {
                        echo "📦 Installing Bun dependencies..."
                        sh 'bun install'
                    } else {
                        echo "📦 Verifying PowerShell environment..."
                        sh 'pwsh -version'
                    }
                }
            }
        }

        stage('Execute Sync') {
            steps {
                script {
                    if (params.SCRIPT_LANGUAGE == 'TypeScript (Bun)') {
                        echo "⚡ Executing TypeScript Logic..."
                        sh 'bun run src/typescript/index.ts'
                    } else {
                        echo "⚡ Executing PowerShell Logic..."
                        sh 'pwsh ./src/powershell/Invoke-Sync.ps1'
                    }
                }
            }
        }
    }

    post {
        always {
            echo "📝 Archiving execution logs..."
        }
    }
}
