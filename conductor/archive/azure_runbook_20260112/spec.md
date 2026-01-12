# Track Specification: Simplified Azure Runbook Script

## Overview
Create a streamlined, single-file PowerShell script designed specifically for execution within Azure Automation Runbooks. This script will replace the complex Jenkins-based orchestration for the HiBob-to-Teams profile sync, utilizing Azure-native security features like Managed Identity.

## Functional Requirements
1.  **Authentication:**
    *   Authenticate to Microsoft Graph and Azure resources using **System-assigned Managed Identity**.
    *   Eliminate the need for client secrets or certificate handling within the script.
2.  **Secret Retrieval:**
    *   Connect to **Azure Key Vault** using the same Managed Identity context.
    *   Securely retrieve the `HiBob-API-Token` at runtime.
3.  **Core Logic:**
    *   Fetch avatar URLs from the HiBob API.
    *   Update user profile photos in Microsoft Teams (Entra ID) via Microsoft Graph.
    *   Implement "Delta Sync" logic (or efficient updates) to minimize API calls.
4.  **Logging & Monitoring:**
    *   Implement structured or verbose logging suitable for Azure Automation output streams.
    *   Ensure success/failure states are clearly reported for monitoring tools.

## Non-Functional Requirements
*   **Location:** The script must be created in a new dedicated subfolder (e.g., `azure-automation/`) to ensure it does not overwrite or interfere with the current Jenkins-based project structure.
*   **Single-File Architecture:** The solution should be self-contained in a single `.ps1` file (or minimal dependencies) to simplify Runbook deployment.
*   **No Jenkins Dependencies:** Remove all logic related to Jenkins environment variables or parameters.
*   **Error Handling:** Robust error catching to ensure the Runbook completes gracefully even if individual user syncs fail.

## Out of Scope
*   User-assigned Managed Identity support (System-assigned only for this iteration).
*   Jenkins pipeline modifications (this is a standalone alternative).
