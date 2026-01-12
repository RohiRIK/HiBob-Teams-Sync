# Technology Stack

## Primary Languages
*   **TypeScript:** Main logic for API orchestration and image processing.
*   **PowerShell Core:** Alternative runtime for environments where PowerShell is preferred.

## Runtimes & Orchestration
*   **Bun:** Primary execution engine for the TypeScript codebase.
*   **Jenkins Pipeline:** Automates the scheduled execution and parameter handling.

## APIs & External Services
*   **HiBob API:** HRIS source for employee metadata and avatar URLs.
*   **Microsoft Graph API:** Target service for updating profile photos in Microsoft 365 (Entra ID).

## Security & Secrets
*   **Jenkins Credentials Binding:** Secure injection of API tokens and secrets into the environment.
*   **Vault Integration:** Backend storage for sensitive credentials.
