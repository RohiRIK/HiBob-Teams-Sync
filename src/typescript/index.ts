import { config, validateConfig } from "./config";
import { HiBobService } from "./hibob";
import { GraphService } from "./graph";
import { Logger } from "./logger";

const CTX = "Main";

async function main() {
    validateConfig();

    if (config.isDryRun) {
        Logger.warn(CTX, "⚠️ MODE: DRY RUN (Safe Mode) - No changes will be applied.");
    }

    const hibob = new HiBobService();
    const graph = new GraphService();

    Logger.info(CTX, "📥 Fetching employee list from HiBob...");
    const employees = await hibob.getEmployees();
    
    // Filter for Test User if specified
    const targetEmployees = config.testUserEmail 
        ? employees.filter(e => e.email.toLowerCase() === config.testUserEmail!.toLowerCase())
        : employees;

    if (config.testUserEmail && targetEmployees.length === 0) {
        Logger.error(CTX, `❌ Test User ${config.testUserEmail} not found in HiBob.`);
        process.exit(1);
    }

    Logger.info(CTX, `ℹ️ Processing ${targetEmployees.length} users...`);

    for (const emp of targetEmployees) {
        if (!emp.email) {
            Logger.warn(CTX, `Skipping user ${emp.id} - No Email Address`);
            continue;
        }

        if (config.syncAvatars) {
            const avatarUrl = await hibob.getAvatarUrl(emp.id);
            if (avatarUrl) {
                await graph.updateProfilePhoto(emp.email, avatarUrl);
            } else {
                // Logger.debug(CTX, `No avatar for ${emp.email}`);
            }
        }
    }
}

main().catch(err => Logger.error(CTX, "Critical Execution Failure", err));
