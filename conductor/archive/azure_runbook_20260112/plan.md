# Track Plan: Simplified Azure Runbook Script

## Phase 1: Setup & Authentication Logic
- [x] Task: Create new directory `azure-automation/` and empty script file `Sync-HiBobToTeams-Runbook.ps1`. (f8f03a6)
- [x] Task: Implement authentication logic using `Connect-AzAccount -Identity` and `Connect-MgGraph -Identity`. (d8452a7)
- [x] Task: Implement Azure Key Vault retrieval logic for the HiBob token. (4757ae1)
- [x] Task: Write tests for authentication and secret retrieval (mocking Azure cmdlets). (5a1f7e1)
- [ ] Task: Conductor - User Manual Verification 'Setup & Authentication Logic' (Protocol in workflow.md)

## Phase 2: Core Sync Logic Implementation
- [ ] Task: Port and simplify HiBob API fetching logic from existing modules to the single script.
- [ ] Task: Port and simplify Microsoft Graph update logic (photo upload) to the single script.
- [ ] Task: Implement efficient logging (monitoring-friendly) within the loop.
- [ ] Task: Write unit tests for the sync logic (mocking API responses).
- [ ] Task: Conductor - User Manual Verification 'Core Sync Logic Implementation' (Protocol in workflow.md)

## Phase 3: Final Integration & Verification
- [ ] Task: Refine error handling to ensure graceful degradation (continue on error).
- [ ] Task: Perform a dry-run test of the full script (mocking the environment).
- [ ] Task: Conductor - User Manual Verification 'Final Integration & Verification' (Protocol in workflow.md)
