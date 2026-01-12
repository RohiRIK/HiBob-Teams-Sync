# Track Specification: Fix API Headers & Enhance Logging

## Overview
Address the critical "Unsupported Media Type" API error preventing HiBob synchronization and simultaneously overhaul the logging system to provide high-fidelity observability. This track introduces a "Verbose Mode" that can be triggered explicitly or automatically during dry runs.

## Functional Requirements
1.  **Fix HiBob API Error:**
    *   Investigate and fix the `Unsupported Media Type` (HTTP 415) error in `hibob.ts`.
    *   Ensure all API requests include correct `Content-Type` and `Accept` headers.
2.  **Enhanced Logging System:**
    *   **Structure:** All logs must include `[TIMESTAMP] [LEVEL] [CONTEXT] Message`.
    *   **Granularity:**
        *   Log every API Request URL and Method.
        *   Log every API Response Status Code.
        *   Log "Start" and "End" of processing for each individual user.
        *   Log specific decision logic (e.g., "Skipping update: Hashes match").
3.  **Control Logic (Hybrid):**
    *   Introduce a new Jenkins boolean parameter: `DEBUG_MODE`.
    *   Enable Verbose Logging if `DRY_RUN` is true **OR** `DEBUG_MODE` is true.

## Non-Functional Requirements
*   **Error Visibility:** Ensure the script exits with a non-zero code (e.g., `process.exit(1)`) upon critical failure so Jenkins marks the build as FAILED (fixing the false positive "SUCCESS").
*   **Readability:** Keep logs human-readable in the Jenkins Console (avoid dumping massive raw JSON objects unless absolutely necessary for debugging).

## Out of Scope
*   Changing the core sync logic (Delta Sync algorithm remains the same, just better logging around it).
