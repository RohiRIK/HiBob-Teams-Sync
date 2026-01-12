pipeline {
    agent any

    parameters {
        choice(
            name: 'SCRIPT_LANGUAGE',
            choices: ['TypeScript (Bun)', 'PowerShell (Core)'],
            description: 'Select the runtime engine for the synchronization logic.'
        )
        string(name: 'TEST_USER_EMAIL', defaultValue: '', description: 'Enter a single email to test the sync safely on one user.')
        booleanParam(name: 'DRY_RUN', defaultValue: true, description: 'If checked, logs intended changes but does not write to Microsoft 365.')
        booleanParam(name: 'SYNC_AVATARS', defaultValue: true, description: 'Master toggle for the profile picture sync feature.')
        booleanParam(name: 'DEBUG_MODE', defaultValue: false, description: 'If checked, enables verbose logging for troubleshooting.')
    }

    environment {
        HIBOB_TOKEN = credentials('hibob-api-token')
        AZURE_CLIENT_ID = credentials('azure-app-client-id')
        AZURE_CLIENT_SECRET = credentials('azure-app-client-secret')
        AZURE_TENANT_ID = credentials('azure-tenant-id')
        IS_DRY_RUN = "${params.DRY_RUN}"
        DO_SYNC_AVATARS = "${params.SYNC_AVATARS}"
        DEBUG_MODE = "${params.DEBUG_MODE}"
    }

    stages {
        stage('Prepare Runtime') {
            steps {
                script {
                    if (params.SCRIPT_LANGUAGE == 'TypeScript (Bun)') {
                        echo "📦 Checking/Installing Bun..."
                        sh '''
                            if ! command -v bun &> /dev/null; then
                                curl -fsSL https://bun.sh/install | bash
                            fi
                            export BUN_INSTALL="$HOME/.bun"
                            export PATH="$BUN_INSTALL/bin:$PATH"
                            bun install
                        '''
                    } else {
                        echo "📦 Unblocking PowerShell files..."
                        sh 'pwsh -Command "Get-ChildItem -Recurse | Unblock-File"'
                    }
                }
            }
        }

        stage('Execute Sync') {
            steps {
                script {
                    if (params.SCRIPT_LANGUAGE == 'TypeScript (Bun)') {
                        echo "⚡ Executing TypeScript Logic (Bun)..."
                        sh '''
                            export BUN_INSTALL="$HOME/.bun"
                            export PATH="$BUN_INSTALL/bin:$PATH"
                            bun start
                        '''
                    } else {
                        echo "⚡ Executing PowerShell Logic..."
                        sh 'pwsh -File src/powershell/Invoke-Sync.ps1'
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