# Dead Code Analysis Report

**Generated:** 2026-02-24
**Project:** HiBob-Teams-Sync

---

## Summary

| Category | Count |
|----------|-------|
| Files Analyzed | 25+ |
| Safe to Delete | 3 |
| Needs Investigation | 4 |
| Active Code | 18+ |

---

## Findings by Severity

### 🔴 DANGER - Do Not Delete
These files are actively used in CI/CD or serve as entry points:

| File | Purpose | Status |
|------|---------|--------|
| `Jenkinsfile` | CI/CD pipeline - runs both TS and PS | **ACTIVE** |
| `HiBobTeamsSync/src/powershell/Invoke-Sync.ps1` | PowerShell entry point (Jenkins line 72) | **ACTIVE** |
| `HiBobTeamsSync/src/typescript/index.ts` | TypeScript entry point (Jenkins line 66) | **ACTIVE** |
| `HiBobTeamsSync/src/powershell/HiBobSync.psm1` | PowerShell module for avatar sync | **ACTIVE** |

### 🟡 CAUTION - Verify Before Changes

| File | Issue | Recommendation |
|------|-------|----------------|
| `typescript/` folder | Partial duplicate of `HiBobTeamsSync/src/typescript/` | Investigate - different implementations? |
| `HiBobTeamsSync/src/Sync-HiBobToTeams.ps1` | Standalone avatar sync script | Keep - different use case (avatars vs notifications) |
| `HiBobTeamsSync/powershell/Sync-HiBobTeams.ps1` | New hire notifications (our new work) | Keep - different use case |
| `azure-automation/` | Azure Runbook for production | Keep - different deployment method |

### 🟢 SAFE - Can Delete

| File | Reason | Recommendation |
|------|--------|----------------|
| `HiBobTeamsSync/powershell/tests/mocks/Mock-HiBobApi.ps1` | Backup HTTP server - not used (we use Pester Mock) | **DELETE** |
| `HiBobTeamsSync/powershell/tests/mocks/Mock-TeamsWebhook.ps1` | Backup HTTP server - not used (we use Pester Mock) | **DELETE** |
| `HiBobTeamsSync/powershell/run-tests.ps1` | Duplicate test runner (Pester can run directly) | **DELETE** |

---

## Project Structure Understanding

The project has **two distinct use cases**:

1. **Avatar Sync** (profile pictures)
   - Scripts: `src/powershell/Invoke-Sync.ps1`, `src/Sync-HiBobToTeams.ps1`
   - Uses: Microsoft Graph SDK
   - Triggered by: `DO_SYNC_AVATARS=true`

2. **New Hire Notifications** (Teams webhooks)
   - Scripts: `powershell/Sync-HiBobTeams.ps1`
   - Uses: Teams Incoming Webhooks
   - Our new work in `feature/powershell-sync-with-mocks`

---

## Recommended Actions

### Immediate (Safe)
```bash
# Delete backup HTTP mock servers
rm HiBobTeamsSync/powershell/tests/mocks/Mock-HiBobApi.ps1
rm HiBobTeamsSync/powershell/tests/mocks/Mock-TeamsWebhook.ps1
rm HiBobTeamsSync/powershell/run-tests.ps1
```

### Investigate Later
- Compare `typescript/` vs `HiBobTeamsSync/src/typescript/` for consolidation
- Consider merging avatar sync scripts to single entry point

---

## Test Verification

All tests pass before cleanup:
```
Tests Passed: 20, Failed: 0
```
