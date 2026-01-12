# Sync-HiBobToTeams-Runbook.Tests.ps1

Describe "Sync-HiBobToTeams-Runbook Authentication" {
    Context "When parameters are valid" {
        It "Should authenticate to Azure and retrieve the secret" {
            # Mocking Cmdlets
            Mock Connect-AzAccount { return @{ Context = @{ Account = @{ Id = "mock-account-id" } } } }
            Mock Get-AzKeyVaultSecret { return "mock-secret-value" }
            Mock Connect-MgGraph { return $true }

            # Execute the script
            { 
                & "$PSScriptRoot/Sync-HiBobToTeams-Runbook.ps1" -KeyVaultName "test-kv" -SecretName "test-secret" 
            } | Should -Not -Throw
        }
    }

    Context "When Key Vault Secret is empty" {
        It "Should throw an error" {
            # Mocking Cmdlets
            Mock Connect-AzAccount { return @{ Context = @{ Account = @{ Id = "mock-account-id" } } } }
            Mock Get-AzKeyVaultSecret { return "" }
            Mock Connect-MgGraph { return $true }
            
            { 
                & "$PSScriptRoot/Sync-HiBobToTeams-Runbook.ps1" -KeyVaultName "test-kv" -SecretName "test-secret" 
            } | Should -Throw "Failed to retrieve secret: Value is empty."
        }
    }
}
