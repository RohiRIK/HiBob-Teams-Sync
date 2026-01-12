import { expect, test, describe } from "bun:test";
import { HiBobService } from "./hibob";

describe("HiBobService", () => {
    test("should have correct headers configured", () => {
        process.env.HIBOB_TOKEN = "test-token";
        const service = new HiBobService();
        // Accessing private headers for testing purposes
        const headers = (service as any).headers;
        
        expect(headers['Content-Type']).toBe('application/json');
        expect(headers['Accept']).toBe('application/json');
    });
});
