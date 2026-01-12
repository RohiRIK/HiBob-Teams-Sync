import { config, validateConfig } from "./config";
import { HiBobService } from "./hibob";
import { GraphService } from "./graph";
import { Logger } from "./logger";

const CTX = "Main";

async function main() {
    if (!validateConfig()) {
        process.exit(1);
    }

    if (config.isDryRun) {
        Logger.warn(CTX, "⚠️ MODE: DRY RUN (Safe Mode) - No changes will be applied.");
    }

    if (config.verbose) {
        Logger.info(CTX, "🔍 VERBOSE LOGGING ENABLED");
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

    // Apply safety limit if specified
    let finalEmployees = targetEmployees;
    if (config.maxUsers > 0 && !config.testUserEmail) {
        Logger.warn(CTX, `⚠️ Safety Limit Active: Processing only the first ${config.maxUsers} users.`);
        finalEmployees = targetEmployees.slice(0, config.maxUsers);
    }

    Logger.info(CTX, `ℹ️ Processing ${finalEmployees.length} users...`);

    let successCount = 0;
    let failureCount = 0;

    for (const emp of finalEmployees) {
        Logger.debug(CTX, `--- Starting User: ${emp.email || emp.id} ---`);

        if (!emp.email) {
            Logger.warn(CTX, `Skipping user ${emp.id} - No Email Address`);
            failureCount++;
            continue;
        }

        try {
            if (config.syncAvatars) {
                const avatarUrl = await hibob.getAvatarUrl(emp.id);
                if (avatarUrl) {
                    await graph.updateProfilePhoto(emp.email, avatarUrl);
                    successCount++;
                } else {
                    Logger.debug(CTX, `No avatar found for ${emp.email}`);
                }
            }
        } catch (error) {
            Logger.error(CTX, `Failed to process ${emp.email}`, error);
            failureCount++;
        }

        Logger.debug(CTX, `--- Finished User: ${emp.email} ---`);
    }

    Logger.info(CTX, `🏁 Sync Complete. Success: ${successCount}, Failures: ${failureCount}`);
}

main().catch(err => {
    Logger.error(CTX, "Critical Execution Failure", err);
    process.exit(1); // Ensure non-zero exit on failure
});