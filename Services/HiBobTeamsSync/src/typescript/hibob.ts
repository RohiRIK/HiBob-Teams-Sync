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
        let allEmployees: Employee[] = [];
        let hasMore = true;
        let searchToken: string | undefined = undefined;

        while (hasMore) {
            Logger.debug(CTX, `POST ${url} | Token Length: ${config.hibob.token?.length || 0} characters | searchToken: ${searchToken || 'none'}`);
            
            const body: any = { 
                showInactive: false,
                humanReadable: true 
            };
            if (searchToken) body.searchToken = searchToken;

            const response = await fetch(url, {
                method: 'POST',
                headers: this.headers,
                body: JSON.stringify(body)
            });

            if (!response.ok) {
                Logger.debug(CTX, `Response: ${response.status} ${response.statusText}`);
                throw new Error(`Failed to fetch employees: ${response.statusText}`);
            }

            const data = await response.json();
            const pageEmployees = data.employees.map((e: any) => ({
                id: e.id,
                email: e.email
            }));

            allEmployees = allEmployees.concat(pageEmployees);
            searchToken = data.searchToken;
            hasMore = !!searchToken && pageEmployees.length > 0;

            Logger.debug(CTX, `Page received: ${pageEmployees.length} users. Total so far: ${allEmployees.length}`);
        }

        return allEmployees;
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
