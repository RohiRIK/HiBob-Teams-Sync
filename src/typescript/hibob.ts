import { config } from "./config";

export interface Employee {
    id: string;
    email: string;
}

export class HiBobService {
    private headers = { 'Authorization': config.hibob.token! };

    async getEmployees(): Promise<Employee[]> {
        const response = await fetch(`${config.hibob.apiUrl}/people/search`, {
            method: 'POST',
            headers: this.headers,
            body: JSON.stringify({ showInactive: false })
        });

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
            const response = await fetch(`${config.hibob.apiUrl}/avatars/${employeeId}`, {
                headers: this.headers
            });
            
            if (!response.ok) return null;
            
            const data = await response.json();
            return data.avatarUrl || null;
        } catch (error) {
            console.error(`Error fetching avatar for ${employeeId}:`, error);
            return null;
        }
    }
}
