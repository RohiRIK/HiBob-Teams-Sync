<#
.SYNOPSIS
    Syncs new hires from HiBob to Microsoft Teams.

.DESCRIPTION
    Refactored version using modules.
    Fetches employees from HiBob who started within the last N days and posts a welcome message to a Teams channel via Webhook.

.PARAMETER DaysLookback
    Number of days to look back for new hires. Default is 7.
#>

param(
    [int]$DaysLookback = 7
)

# Import Modules
# Using $PSScriptRoot to ensure we find modules relative to this script
Import-Module -Force "$PSScriptRoot/Modules/HiBob.psm1"
Import-Module -Force "$PSScriptRoot/Modules/Teams.psm1"

# Configuration & Validation
$HiBobToken = $env:HIBOB_TOKEN
# Default to V1 API if not set
$HiBobApiUrl = if ($env:HIBOB_API_URL) { $env:HIBOB_API_URL } else { "https://api.hibob.com/v1" }
$TeamsWebhookUrl = $env:TEAMS_WEBHOOK_URL
$IsDryRun = $env:DRY_RUN -eq 'true'

if (-not $HiBobToken -or -not $TeamsWebhookUrl) {
    Write-Error "Missing required environment variables: HIBOB_TOKEN, TEAMS_WEBHOOK_URL"
    exit 1
}

# Main Execution
try {
    $NewHires = Get-HiBobNewHires -Token $HiBobToken -ApiUrl $HiBobApiUrl -Lookback $DaysLookback -DryRun:$IsDryRun
    
    if ($NewHires.Count -eq 0) {
        Write-Host "No new hires found."
        exit 0
    }

    foreach ($Hire in $NewHires) {
        Send-TeamsNotification -Employee $Hire -WebhookUrl $TeamsWebhookUrl -DryRun:$IsDryRun
    }
    
    Write-Host "Sync completed successfully."

}
catch {
    Write-Error "Critical error in sync process: $_"
    exit 1
}
