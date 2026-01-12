# Modules/HiBob.psm1

function Get-HiBobNewHires {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Token,
        
        [Parameter(Mandatory = $true)]
        [string]$ApiUrl,

        [int]$Lookback = 7,
        
        [switch]$DryRun
    )
    
    Write-Host "Fetching HiBob new hires from the last $Lookback days..."
    
    $Url = "$ApiUrl/people/search"
    $Headers = @{
        "Authorization" = $Token
        "Content-Type"  = "application/json"
        "Accept"        = "application/json"
    }
    
    if ($DryRun) {
        Write-Host "[DRY RUN] Would POST to $Url"
        return @(
            [PSCustomObject]@{
                id        = "123"
                firstName = "Dry"
                surname   = "Run"
                email     = "dry@run.com"
                work      = [PSCustomObject]@{
                    startDate  = (Get-Date).ToString("yyyy-MM-dd")
                    title      = "Test User"
                    department = "Testing"
                }
            }
        )
    }

    try {
        $Body = @{
            showInactive  = $false
            humanReadable = $true
        } | ConvertTo-Json

        $Response = Invoke-RestMethod -Uri $Url -Method Post -Headers $Headers -Body $Body
        $Employees = $Response.employees
        
        $CutoffDate = (Get-Date).AddDays(-$Lookback)
        
        $NewHires = $Employees | Where-Object { 
            $_.work.startDate -and ([DateTime]$_.work.startDate -ge $CutoffDate)
        }
        
        Write-Host "Found $($NewHires.Count) new hires."
        return $NewHires

    }
    catch {
        Write-Error "Failed to fetch from HiBob: $_"
        throw
    }
}

Export-ModuleMember -Function Get-HiBobNewHires
