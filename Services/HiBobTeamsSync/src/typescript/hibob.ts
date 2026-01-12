import { config } from "./config";
import { Logger } from "./logger";

const CTX = "HiBob";

export interface Employee {
    id: string;
    email: string;
}

export class HiBobService {
    private headers = { 
        'Authorization': config.hibob.token!,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    };

    async getEmployees(): Promise<Employee[]> {
        const url = `${config.hibob.apiUrl}/people/search`;
        Logger.debug(CTX, `POST ${url} | Token Length: ${config.hibob.token?.length || 0} characters`);
        Logger.debug(CTX, `Payload: { showInactive: false }`);

        const response = await fetch(url, {
            method: 'POST',
            headers: this.headers,
            body: JSON.stringify({ showInactive: false })
        });

        Logger.debug(CTX, `Response: ${response.status} ${response.statusText}`);

        if (!response.ok) {
            throw new Error(`Failed to fetch employees: ${response.statusText}`);
        }

        const data = await response.json();
        return data.employees.map((e: any) => ({
            id: e.id,
            email: e.email
        }));
    }

    async getAvatarUrl(employeeId: string): Promise<string | null> {
        try {
            const url = `${config.hibob.apiUrl}/avatars/${employeeId}`;
            Logger.debug(CTX, `GET ${url}`);

            const response = await fetch(url, {
                headers: this.headers
            });
            
            Logger.debug(CTX, `Response: ${response.status} ${response.statusText}`);
            
            if (!response.ok) return null;
            
            const data = await response.json();
            return data.avatarUrl || null;
        } catch (error) {
            Logger.error(CTX, `Error fetching avatar for ${employeeId}`, error);
            return null;
        }
    }
}