# Modules/Teams.psm1

function Send-TeamsNotification {
    param(
        [Parameter(Mandatory = $true)]
        $Employee,

        [Parameter(Mandatory = $true)]
        [string]$WebhookUrl,

        [switch]$DryRun
    )

    Write-Host "Sending Teams notification for $($Employee.firstName) $($Employee.surname)..."

    $Card = @{
        type        = "message"
        attachments = @(
            @{
                contentType = "application/vnd.microsoft.card.adaptive"
                contentUrl  = $null
                content     = @{
                    '$schema' = "http://adaptivecards.io/schemas/adaptive-card.json"
                    type      = "AdaptiveCard"
                    version   = "1.2"
                    body      = @(
                        @{
                            type   = "TextBlock"
                            text   = "🚀 New Team Member!"
                            weight = "Bolder"
                            size   = "Large"
                            color  = "Accent"
                        },
                        @{
                            type = "TextBlock"
                            text = "Please welcome **$($Employee.firstName) $($Employee.surname)** to the team!"
                            wrap = $true
                            size = "Medium"
                        },
                        @{
                            type  = "FactSet"
                            facts = @(
                                @{ title = "Title:"; value = ($Employee.work.title) },
                                @{ title = "Department:"; value = ($Employee.work.department) },
                                @{ title = "Start Date:"; value = ($Employee.work.startDate) },
                                @{ title = "Email:"; value = ($Employee.email) }
                            )
                        }
                    )
                }
            }
        )
    }

    if ($DryRun) {
        Write-Host "[DRY RUN] Would POST to Teams Webhook"
        return
    }

    try {
        Invoke-RestMethod -Uri $WebhookUrl -Method Post -ContentType "application/json" -Body ($Card | ConvertTo-Json -Depth 10)
        Write-Host "Notification sent successfully."
    }
    catch {
        Write-Error "Failed to send Teams notification: $_"
    }
}

Export-ModuleMember -Function Send-TeamsNotification
