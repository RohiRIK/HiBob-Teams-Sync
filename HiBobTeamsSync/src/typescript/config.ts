export const config = {
    hibob: {
        token: process.env.HIBOB_TOKEN,
        apiUrl: "https://api.hibob.com/v1"
    },
    azure: {
        clientId: process.env.AZURE_CLIENT_ID,
        clientSecret: process.env.AZURE_CLIENT_SECRET,
        tenantId: process.env.AZURE_TENANT_ID,
        authority: `https://login.microsoftonline.com/${process.env.AZURE_TENANT_ID}`
    },
    isDryRun: process.env.IS_DRY_RUN === 'true',
    testUserEmail: process.env.TEST_USER_EMAIL || null,
    syncAvatars: process.env.DO_SYNC_AVATARS === 'true',
    verbose: (process.env.IS_DRY_RUN === 'true') || (process.env.DEBUG_MODE === 'true'),
    maxUsers: parseInt(process.env.MAX_USERS || '0', 10),
    buildTestOnly: process.env.BUILD_TEST_ONLY === 'true'
};

export function validateConfig(): boolean {
    const missing = [];
    if (!config.hibob.token) missing.push("HIBOB_TOKEN");
    if (!config.azure.clientId) missing.push("AZURE_CLIENT_ID");
    if (!config.azure.clientSecret) missing.push("AZURE_CLIENT_SECRET");
    if (!config.azure.tenantId) missing.push("AZURE_TENANT_ID");

    if (missing.length > 0) {
        console.error(`❌ Missing required environment variables: ${missing.join(", ")}`);
        return false;
    }
    return true;
}
