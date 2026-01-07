import { config } from "./config";
import { Logger } from "./logger";

export class GraphService {
    private token: string | null = null;
    private context = "GraphService";

    private async getToken(): Promise<string> {
        if (this.token) return this.token;

        try {
            const params = new URLSearchParams();
            params.append('client_id', config.azure.clientId!);
            params.append('scope', 'https://graph.microsoft.com/.default');
            params.append('client_secret', config.azure.clientSecret!);
            params.append('grant_type', 'client_credentials');

            const res = await fetch(`${config.azure.authority}/oauth2/v2.0/token`, {
                method: 'POST',
                body: params
            });

            const data = await res.json();
            if (!res.ok) throw new Error(`Auth Error: ${JSON.stringify(data)}`);
            
            this.token = data.access_token;
            return this.token!;
        } catch (error) {
            Logger.error(this.context, "Failed to acquire Graph Token", error);
            throw error;
        }
    }

    async updateProfilePhoto(email: string, avatarUrl: string): Promise<void> {
        if (config.isDryRun) {
            Logger.info(this.context, `[DRY RUN] Would upload photo for ${email}`);
            return;
        }

        try {
            // 1. Download image
            const imgRes = await fetch(avatarUrl);
            if (!imgRes.ok) throw new Error(`Failed to download avatar from Bob: ${imgRes.statusText}`);
            const imgBlob = await imgRes.arrayBuffer();

            // 2. Upload to Graph
            const token = await this.getToken();
            const graphRes = await fetch(`https://graph.microsoft.com/v1.0/users/${email}/photo/$value`, {
                method: 'PUT',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'image/jpeg'
                },
                body: imgBlob
            });

            if (!graphRes.ok) {
                const errText = await graphRes.text();
                throw new Error(`Graph API ${graphRes.status}: ${errText}`);
            }
            Logger.info(this.context, `✅ Success: Updated photo for ${email}`);
        } catch (error) {
            Logger.error(this.context, `❌ Failed to update ${email}`, error);
        }
    }
}