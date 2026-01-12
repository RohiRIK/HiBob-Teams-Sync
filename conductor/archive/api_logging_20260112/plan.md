# Track Plan: Fix API Headers & Enhance Logging

## Phase 1: API Fix & Parameter Update
- [x] Task: Update `hibob.ts` headers to include `Accept` and `Content-Type` to fix HTTP 415 error. (fixed415)
- [x] Task: Modify `Jenkinsfile` to add the `DEBUG_MODE` boolean parameter. (jenkins_debug)
- [x] Task: Update `config.ts` to parse `DEBUG_MODE` env var and export a `verbose` flag (`dryRun || debugMode`). (config_verbose)
- [x] Task: Relocate Jenkins pipeline to `Jenkins/FreshService/HiBobTeamsSync/HiBobTeamsSync.groovy`. (jenkins_relocate)
- [x] Task: Conductor - User Manual Verification 'API Fix & Parameter Update' (Protocol in workflow.md)

## Phase 2: Logging Overhaul
- [x] Task: Refactor `logger.ts` to support timestamped, leveled logging and the new `verbose` flag. (logger_v2)
- [x] Task: Instrument `hibob.ts` with verbose logs (Request/Response details). (log_hibob)
- [x] Task: Instrument `graph.ts` with verbose logs (Request/Response details). (log_graph)
- [x] Task: Instrument `index.ts` with user-level tracking logs (Start/End/Skip). (log_index)
- [x] Task: Ensure `process.exit(1)` is called on critical errors in `index.ts`. (exit_fail)
- [x] Task: Conductor - User Manual Verification 'Logging Overhaul' (Protocol in workflow.md)

## Phase 3: Verification
- [x] Task: Run unit tests to verify header logic. (test_headers)
- [x] Task: Perform a local dry-run (simulating Jenkins) to verify log output format. (verify_logs)
- [x] Task: Conductor - User Manual Verification 'Verification' (Protocol in workflow.md)
