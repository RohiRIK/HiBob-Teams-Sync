import { config } from "./config";

export class Logger {
    private static getTimestamp(): string {
        return new Date().toISOString();
    }

    private static format(level: string, context: string, message: string): string {
        return `[${this.getTimestamp()}] [${level.toUpperCase()}] [${context}] ${message}`;
    }

    static info(context: string, message: string) {
        console.log(this.format('INFO', context, message));
    }

    static warn(context: string, message: string) {
        console.warn(this.format('WARN', context, message));
    }

    static error(context: string, message: string, error?: any) {
        const errMsg = error instanceof Error ? error.message : JSON.stringify(error);
        console.error(this.format('ERROR', context, `${message} | Details: ${errMsg}`));
    }

    /**
     * Logs only if verbose mode is enabled (DRY_RUN or DEBUG_MODE)
     */
    static debug(context: string, message: string) {
        if (config.verbose) {
            console.log(this.format('DEBUG', context, message));
        }
    }
}