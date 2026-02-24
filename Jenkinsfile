pipeline {
    agent any

    parameters {
        choice(
            name: 'SYNC_TYPE',
            choices: ['New Hire Notifications', 'Avatar Sync', 'Both'],
            description: 'Select what to sync: New hires to Teams, Avatars to Teams, or both.'
        )
        string(name: 'TEST_USER_EMAIL', defaultValue: '', description: 'Enter a single email to test the sync safely on one user.')
        booleanParam(name: 'DRY_RUN', defaultValue: true, description: 'If checked, logs intended changes but does not write to Microsoft 365.')
        booleanParam(name: 'DEBUG_MODE', defaultValue: false, description: 'If checked, enables verbose logging for troubleshooting.')
        string(name: 'DAYS_LOOKBACK', defaultValue: '7', description: 'How many days back to look for new hires (default: 7)')
    }

    environment {
        // Common credentials
        HIBOB_TOKEN = credentials('hibob-api-token')
        
        // Azure credentials (for Avatar Sync)
        AZURE_CLIENT_ID = credentials('azure-app-client-id')
        AZURE_CLIENT_SECRET = credentials('azure-app-client-secret')
        AZURE_TENANT_ID = credentials('azure-tenant-id')
        
        // Teams Webhook (for New Hire Notifications)
        TEAMS_WEBHOOK_URL = credentials('teams-webhook-url')
        
        // Parameters
        IS_DRY_RUN = "${params.DRY_RUN}"
        DEBUG_MODE = "${params.DEBUG_MODE}"
    }

    stages {
        stage('Prepare Runtime') {
            steps {
                script {
                    // Check and install PowerShell if needed
                    echo "🔍 Checking for PowerShell..."
                    sh '''
                        if command -v pwsh &> /dev/null; then
                            echo "✅ PowerShell already installed: $(pwsh --version)"
                            echo "PWSH_PATH=$(which pwsh)" > /tmp/runtime_paths.txt
                        else
                            echo "📦 Installing PowerShell..."
                            if [ ! -d "/var/jenkins_home/powershell" ]; then
                                curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/powershell-7.4.1-linux-x64.tar.gz -o /tmp/powershell.tar.gz
                                mkdir -p /var/jenkins_home/powershell
                                tar -xvf /tmp/powershell.tar.gz -C /var/jenkins_home/powershell
                                chmod +x /var/jenkins_home/powershell/pwsh
                                rm /tmp/powershell.tar.gz
                            fi
                            echo "✅ PowerShell installed"
                            echo "PWSH_PATH=/var/jenkins_home/powershell" > /tmp/runtime_paths.txt
                        fi
                    '''
                    
                    // Check and install Bun only if needed for Avatar Sync
                    if (params.SYNC_TYPE == 'Avatar Sync' || params.SYNC_TYPE == 'Both') {
                        echo "🔍 Checking for Bun..."
                        sh '''
                            if command -v bun &> /dev/null; then
                                echo "✅ Bun already installed: $(bun --version)"
                                echo "BUN_PATH=$(which bun)" >> /tmp/runtime_paths.txt
                            else
                                echo "📦 Installing Bun..."
                                curl -fsSL https://bun.sh/install | bash
                                echo "BUN_PATH=$HOME/.bun/bin" >> /tmp/runtime_paths.txt
                            fi
                            
                            # Install Node modules if needed
                            if [ -d "HiBobTeamsSync" ] && [ ! -d "HiBobTeamsSync/node_modules" ]; then
                                cd HiBobTeamsSync
                                if command -v bun &> /dev/null; then
                                    bun install
                                elif [ -f "package.json" ]; then
                                    npm install
                                fi
                                cd ..
                            fi
                        '''
                    }
                }
            }
        }

        stage('Sync New Hires to Teams') {
            when {
                expression { params.SYNC_TYPE == 'New Hire Notifications' || params.SYNC_TYPE == 'Both' }
            }
            steps {
                script {
                    echo "🔔 Syncing new hires to Microsoft Teams..."
                    sh '''
                        # Load PATH from previous stage
                        if [ -f /tmp/runtime_paths.txt ]; then
                            source /tmp/runtime_paths.txt
                        fi
                        
                        # Use custom path if set, otherwise use system
                        if [ -n "$PWSH_PATH" ]; then
                            export PATH="$PWSH_PATH:$PATH"
                        fi
                        
                        echo "Using PowerShell: $(which pwsh)"
                        
                        export DRY_RUN="${params.DRY_RUN}"
                        export HIBOB_API_URL="https://api.hibob.com/v1"
                        pwsh -File HiBobTeamsSync/powershell/Sync-HiBobTeams.ps1 -DaysLookback ''' + params.DAYS_LOOKBACK + '''
                    '''
                }
            }
        }

        stage('Sync Avatars to Teams') {
            when {
                expression { params.SYNC_TYPE == 'Avatar Sync' || params.SYNC_TYPE == 'Both' }
            }
            steps {
                script {
                    echo "📸 Syncing profile pictures to Microsoft Teams..."
                    sh '''
                        # Load PATH from previous stage
                        if [ -f /tmp/runtime_paths.txt ]; then
                            source /tmp/runtime_paths.txt
                        fi
                        
                        # Use custom paths if set
                        if [ -n "$BUN_PATH" ]; then
                            export PATH="$BUN_PATH:$PATH"
                        fi
                        if [ -n "$PWSH_PATH" ]; then
                            export PATH="$PWSH_PATH:$PATH"
                        fi
                        
                        echo "Using Bun: $(which bun)"
                        echo "Using PowerShell: $(which pwsh)"
                        
                        if [ -n "''' + params.TEST_USER_EMAIL + '''" ]; then
                            export TEST_USER_EMAIL="''' + params.TEST_USER_EMAIL + '''"
                        fi
                        
                        cd HiBobTeamsSync
                        pwsh -File src/powershell/Invoke-Sync.ps1
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "📝 Archiving execution logs..."
            // Clean up temp file
            sh 'rm -f /tmp/runtime_paths.txt'
        }
        success {
            echo "✅ Sync completed successfully!"
        }
        failure {
            echo "❌ Sync failed. Check logs for details."
        }
    }
}
