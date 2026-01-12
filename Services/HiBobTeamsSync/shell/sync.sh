#!/bin/sh

# Sync-HiBobTeams (Shell Version)
# Dependencies: curl, jq

set -e

# Configuration
HIBOB_TOKEN="${HIBOB_TOKEN}"
HIBOB_API_URL="${HIBOB_API_URL:-https://api.hibob.com/v1}"
TEAMS_WEBHOOK_URL="${TEAMS_WEBHOOK_URL}"
IS_DRY_RUN="${DRY_RUN}"
DAYS_LOOKBACK="${1:-7}"

# Validation
if [ -z "$HIBOB_TOKEN" ] || [ -z "$TEAMS_WEBHOOK_URL" ]; then
    echo "Error: Missing required environment variables: HIBOB_TOKEN, TEAMS_WEBHOOK_URL"
    exit 1
fi

send_teams_notification() {
    local first_name="$1"
    local last_name="$2"
    local title="$3"
    local dept="$4"
    local start_date="$5"
    local email="$6"

    echo "Sending Teams notification for $first_name $last_name..."

    # Construct JSON payload manually (careful with escaping)
    # Using a heredoc and jq to safely construct the JSON is safer
    PAYLOAD=$(jq -n \
        --arg fn "$first_name" \
        --arg ln "$last_name" \
        --arg title "$title" \
        --arg dept "$dept" \
        --arg start "$start_date" \
        --arg email "$email" \
        '{
            type: "message",
            attachments: [{
                contentType: "application/vnd.microsoft.card.adaptive",
                contentUrl: null,
                content: {
                    "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                    type: "AdaptiveCard",
                    version: "1.2",
                    body: [
                        { type: "TextBlock", text: "🚀 New Team Member!", weight: "Bolder", size: "Large", color: "Accent" },
                        { type: "TextBlock", text: "Please welcome **\($fn) \($ln)** to the team!", wrap: true, size: "Medium" },
                        { type: "FactSet", facts: [
                            { title: "Title:", value: $title },
                            { title: "Department:", value: $dept },
                            { title: "Start Date:", value: $start },
                            { title: "Email:", value: $email }
                        ]}
                    ]
                }
            }]
        }')

    if [ "$IS_DRY_RUN" = "true" ]; then
        echo "[DRY RUN] Would POST to Teams Webhook"
        return
    fi

    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$TEAMS_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "$PAYLOAD")

    if [ "$HTTP_STATUS" -ne 200 ] && [ "$HTTP_STATUS" -ne 202 ]; then
        echo "Error: Teams Webhook returned status $HTTP_STATUS"
    else
        echo "Notification sent successfully."
    fi
}

# Main

echo "Fetching HiBob new hires from the last $DAYS_LOOKBACK days..."

if [ "$IS_DRY_RUN" = "true" ]; then
    echo "[DRY RUN] Would execute search against people/search"
    # Execute mock
    send_teams_notification "Dry" "Run" "Test User" "Testing" "$(date +%Y-%m-%d)" "dry@run.com"
    exit 0
fi

# Fetch employees
# Note: Using a temp file for the response
TMP_RESPONSE=$(mktemp)
HTTP_STATUS=$(curl -s -w "%{http_code}" -X POST "$HIBOB_API_URL/people/search" \
    -H "Authorization: $HIBOB_TOKEN" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d '{ "showInactive": false, "humanReadable": true }' \
    -o "$TMP_RESPONSE")

if [ "$HTTP_STATUS" -ne 200 ]; then
    echo "Error: HiBob API returned status $HTTP_STATUS"
    cat "$TMP_RESPONSE"
    rm "$TMP_RESPONSE"
    exit 1
fi

# Calculate cutoff date in seconds (epoch)
if date -v -"${DAYS_LOOKBACK}"d >/dev/null 2>&1; then
   # BSD/Mac date
   CUTOFF_EPOCH=$(date -v -"${DAYS_LOOKBACK}"d +%s)
else
   # GNU date
   CUTOFF_EPOCH=$(date -d "${DAYS_LOOKBACK} days ago" +%s)
fi

# Process with jq
# We iterate line by line. 
# 1. Filter employees who have startDate
# 2. Convert startDate to epoch
# 3. Compare with CUTOFF_EPOCH
# 4. Output tab-separated values for safe reading
jq -r --argjson cutoff "$CUTOFF_EPOCH" '
    .employees[] | 
    select(.work.startDate != null) | 
    select((.work.startDate | strptime("%Y-%m-%d") | mktime) >= $cutoff) |
    [
        .firstName, 
        .surname, 
        (.work.title // "N/A"), 
        (.work.department // "N/A"), 
        .work.startDate, 
        (.email // "N/A")
    ] | @tsv
' "$TMP_RESPONSE" | while IFS=$'\t' read -r fname lname title dept start email; do
    if [ -n "$fname" ]; then
        send_teams_notification "$fname" "$lname" "$title" "$dept" "$start" "$email"
    fi
done

rm "$TMP_RESPONSE"
echo "Sync completed successfully."
