# HiBob to Teams Profile Sync (Jenkins Automation)

## 🎯 Goal
Ensure consistent visual identity across the organization by automatically synchronizing employee profile pictures from **HiBob** (HRIS) to **Microsoft Teams** (Entra ID).

## 🏗️ Architecture
*   **Runtime:** Bun + TypeScript (Optimized for speed and developer experience).
*   **Orchestrator:** Jenkins Pipeline (Scheduled Nightly).
*   **Secrets Management:** Jenkins Credentials Binding (Vault).

## ⚙️ Technical Logic

### 1. Source: HiBob
*   **Endpoint:** `GET https://api.hibob.com/v1/avatars/{employeeId}` (or `/people/{id}` for metadata)
*   **Auth:** Custom Header `Authorization: {BOB_TOKEN}`
*   **Data:** Returns the *URL* of the avatar image.

### 2. Logic Layer (Bun)
*   Fetch the avatar URL from HiBob.
*   Download the image binary (Buffer/Blob).
*   Validate size (Microsoft Graph limit: 4MB).

### 3. Sink: Microsoft Graph (Teams/Exchange)
*   **Endpoint:** `PUT https://graph.microsoft.com/v1.0/users/{userPrincipalName}/photo/$value`
*   **Auth:** OAuth2 Client Credentials (App Registration).
*   **Scopes Required:** `User.ReadWrite.All` or `ProfilePhoto.ReadWrite.All`.
*   **Header:** `Content-Type: image/jpeg` (or relevant mime type).

## 🕹️ Jenkins Operations Guide

### 1. First-Time Setup
*   **Job Type:** Create a "Pipeline" job.
*   **SCM:** Point it to your Git repository and set the script path to `Jenkinsfile`.
*   **Initialization:** Run the job **once** manually. It may fail, but this "registers" the parameters into the Jenkins UI.

### 2. Build with Parameters
After initialization, you will see the **"Build with Parameters"** button. This allows you to control the execution without changing code:

| Parameter | Description |
| :--- | :--- |
| **SCRIPT_LANGUAGE** | Choose between **TypeScript (Bun)** or **PowerShell (Core)**. |
| **TEST_USER_EMAIL** | Enter a single email to test the sync safely on one user. |
| **DRY_RUN** | If checked, the script logs intended changes but **does not** write to Microsoft 365. |
| **SYNC_AVATARS** | Master toggle for the profile picture sync feature. |

### 3. How the Language Switch Works
The `Jenkinsfile` acts as a traffic controller. Depending on your choice:
*   **TypeScript:** Jenkins runs `bun install` and executes `src/typescript/index.ts`.
*   **PowerShell:** Jenkins imports the `HiBobSync.psm1` module and executes `src/powershell/Invoke-Sync.ps1`.

### 4. Required Credentials (Vault)
You must create the following **Secret Text** credentials in Jenkins for the automation to work:
*   `hibob-api-token`: Your HiBob API key.
*   `azure-app-client-id`: The Client ID of your Entra ID App.
*   `azure-app-client-secret`: The Secret of your Entra ID App.
*   `azure-tenant-id`: Your Microsoft 365 Tenant ID.

---

## 🔒 Security Requirements
*   **Bob Token:** Read-access to People/Avatars.
*   **Azure App Registration:** 
    *   Client ID & Secret.
    *   Application Permissions (not Delegated).
*   **Jenkins:** Credentials must be injected as environment variables:
    *   `HIBOB_TOKEN`
    *   `AZURE_CLIENT_ID`
    *   `AZURE_CLIENT_SECRET`
    *   `AZURE_TENANT_ID`

## 📜 Master Plan Reference
> "By utilizing a direct Bun -> API pipeline on Jenkins, we eliminate the need for third-party sync engines, maintain absolute data sovereignty, and secure all credentials within the Jenkins Vault."
