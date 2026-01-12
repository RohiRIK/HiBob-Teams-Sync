# Sync-HiBobToTeams-Runbook.ps1
#
# Description: Synchronizes HiBob profile pictures to Microsoft Teams via Azure Automation.
# Authentication: System-assigned Managed Identity.
#

param(
    [Parameter(Mandatory=$true)]
    [string]$KeyVaultName,

    [Parameter(Mandatory=$true)]
    [string]$SecretName = "hibob-api-token"
)

try {
    Write-Output "Starting Sync-HiBobToTeams-Runbook..."

    # 1. Authenticate to Azure (for Key Vault)
    Write-Output "Authenticating to Azure using Managed Identity..."
    $azContext = Connect-AzAccount -Identity -ErrorAction Stop
    Write-Output "Successfully connected to Azure Context: $($azContext.Context.Account.Id)"

    # 2. Retrieve Secret from Key Vault
    Write-Output "Retrieving secret '$SecretName' from Key Vault '$KeyVaultName'..."
    $hibobToken = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -AsPlainText -ErrorAction Stop
    
    if ([string]::IsNullOrWhiteSpace($hibobToken)) {
        throw "Failed to retrieve secret: Value is empty."
    }
    Write-Output "Successfully retrieved HiBob API Token."

    # 3. Authenticate to Microsoft Graph (for Teams/Entra ID)
    Write-Output "Authenticating to Microsoft Graph using Managed Identity..."
    Connect-MgGraph -Identity -ErrorAction Stop
    Write-Output "Successfully connected to Microsoft Graph."

} catch {
    Write-Error "Critical Failure: $_"
    throw $_
}