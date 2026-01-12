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
        string(name: 'MAX_USERS', defaultValue: '0', description: 'Safety limit: Maximum number of users to process (0 for unlimited).')
    }

    environment {
        HIBOB_TOKEN = credentials('hibob-api-token')
        AZURE_CLIENT_ID = credentials('azure-app-client-id')
        AZURE_CLIENT_SECRET = credentials('azure-app-client-secret')
        AZURE_TENANT_ID = credentials('azure-tenant-id')
        IS_DRY_RUN = "${params.DRY_RUN}"
        DO_SYNC_AVATARS = "${params.SYNC_AVATARS}"
        DEBUG_MODE = "${params.DEBUG_MODE}"
        MAX_USERS = "${params.MAX_USERS}"
    }

    stages {
        stage('Prepare Runtime') {
            steps {
                script {
                    dir('Services/HiBobTeamsSync') {
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
                            echo "📦 Checking/Installing PowerShell..."
                            sh '''
                                if ! command -v pwsh &> /dev/null; then
                                    # Install PowerShell Core for Linux (Jenkins default)
                                    curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/powershell-7.4.1-linux-x64.tar.gz -o /tmp/powershell.tar.gz
                                    mkdir -p /var/jenkins_home/powershell
                                    tar -xvf /tmp/powershell.tar.gz -C /var/jenkins_home/powershell
                                    chmod +x /var/jenkins_home/powershell/pwsh
                                fi
                                export PATH="/var/jenkins_home/powershell:$PATH"
                                export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
                                # Unblock-File removed (Not supported/needed on Linux)
                            '''
                        }
                    }
                }
            }
        }

        stage('Execute Sync') {
            steps {
                script {
                    dir('Services/HiBobTeamsSync') {
                        if (params.SCRIPT_LANGUAGE == 'TypeScript (Bun)') {
                            echo "⚡ Executing TypeScript Logic (Bun)..."
                            sh '''
                                export BUN_INSTALL="$HOME/.bun"
                                export PATH="$BUN_INSTALL/bin:$PATH"
                                bun start
                            '''
                        } else {
                            echo "⚡ Executing PowerShell Logic..."
                            sh '''
                                export PATH="/var/jenkins_home/powershell:$PATH"
                                export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
                                pwsh -File src/powershell/Invoke-Sync.ps1
                            '''
                        }
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