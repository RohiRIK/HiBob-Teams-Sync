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
