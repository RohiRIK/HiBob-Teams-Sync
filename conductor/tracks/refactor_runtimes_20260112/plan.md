# Track Plan: Refactor and Standardize Language Runtimes

## Phase 1: Analysis & Infrastructure
- [x] Task: Audit `package.json` files and `Jenkinsfile` for conflicting runtime commands. (audit1)
- [x] Task: Verify local Bun installation and environment compatibility. (bunver)
- [ ] Task: Conductor - User Manual Verification 'Analysis & Infrastructure' (Protocol in workflow.md)

## Phase 2: Manifest Consolidation
- [ ] Task: Merge `typescript/package.json` dependencies into the root `package.json`.
- [ ] Task: Configure root `package.json` scripts to use Bun runtimes.
- [ ] Task: Conductor - User Manual Verification 'Manifest Consolidation' (Protocol in workflow.md)

## Phase 3: Pipeline Update
- [ ] Task: Modify `Jenkinsfile` to replace `npm install` with `bun install` and `node` with `bun run`.
- [ ] Task: Standardize the `SCRIPT_LANGUAGE` parameter logic in Jenkins.
- [ ] Task: Conductor - User Manual Verification 'Pipeline Update' (Protocol in workflow.md)

## Phase 4: Cleanup & Verification
- [ ] Task: Remove redundant `typescript/` nested directory structure if sources are consolidated.
- [ ] Task: Perform a full dry-run sync to verify runtime stability.
- [ ] Task: Conductor - User Manual Verification 'Cleanup & Verification' (Protocol in workflow.md)
