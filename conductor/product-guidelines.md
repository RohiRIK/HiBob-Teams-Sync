# Product Guidelines

## Technical Prose Style
*   **Concise & Action-Oriented:** Documentation and logs should focus on the "What" and "How". Avoid verbose explanations in logs.
*   **Format:** "Action -> Result". Example: "Fetching User ID: 123 -> Success".

## Error Handling Philosophy
*   **Graceful Degradation:** The system must be robust. A failure to sync a single user record (e.g., due to a missing file or specific API error) must NOT halt the entire pipeline. The error should be logged, and the process should continue to the next user.
*   **Clear Reporting:** All errors must be logged with sufficient context (User ID, Error Code) to allow for quick remediation.

## Operational Standards
*   **Idempotency:** Re-running the script multiple times should not produce side effects or duplicate errors.
*   **Transparency:** Logs should clearly distinguish between "No Change Needed" (Delta Sync) and "Update Performed".
