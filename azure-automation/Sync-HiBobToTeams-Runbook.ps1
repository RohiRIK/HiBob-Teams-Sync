# Sync-HiBobToTeams-Runbook.ps1
#
# Description: Synchronizes HiBob profile pictures to Microsoft Teams via Azure Automation.
# Authentication: System-assigned Managed Identity.
#

try {
    Write-Output "Starting Sync-HiBobToTeams-Runbook..."

    # 1. Authenticate to Azure (for Key Vault)
    Write-Output "Authenticating to Azure using Managed Identity..."
    # Using -Identity flag for system-assigned managed identity
    $azContext = Connect-AzAccount -Identity -ErrorAction Stop
    Write-Output "Successfully connected to Azure Context: $($azContext.Context.Account.Id)"

    # 2. Authenticate to Microsoft Graph (for Teams/Entra ID)
    Write-Output "Authenticating to Microsoft Graph using Managed Identity..."
    Connect-MgGraph -Identity -ErrorAction Stop
    Write-Output "Successfully connected to Microsoft Graph."

} catch {
    Write-Error "Critical Authentication Failure: $_"
    throw $_
}
