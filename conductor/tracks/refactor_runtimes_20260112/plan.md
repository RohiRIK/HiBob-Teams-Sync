# Track Plan: Refactor and Standardize Language Runtimes

## Phase 1: Analysis & Infrastructure [checkpoint: 0dd799b]
- [x] Task: Audit `package.json` files and `Jenkinsfile` for conflicting runtime commands. (audit1)
- [x] Task: Verify local Bun installation and environment compatibility. (bunver)
- [ ] Task: Conductor - User Manual Verification 'Analysis & Infrastructure' (Protocol in workflow.md)

## Phase 2: Manifest Consolidation
- [x] Task: Merge `typescript/package.json` dependencies into the root `package.json`. (3898cf6)
- [x] Task: Configure root `package.json` scripts to use Bun runtimes. (3898cf6)
- [ ] Task: Conductor - User Manual Verification 'Manifest Consolidation' (Protocol in workflow.md)

## Phase 3: Pipeline Update [checkpoint: 75a7b3a]
- [x] Task: Modify `Jenkinsfile` to replace `npm install` with `bun install` and `node` with `bun run`. (jenkins_bun)
- [x] Task: Standardize the `SCRIPT_LANGUAGE` parameter logic in Jenkins. (jenkins_bun_param)
- [ ] Task: Conductor - User Manual Verification 'Pipeline Update' (Protocol in workflow.md)

## Phase 4: Cleanup & Verification
- [x] Task: Remove redundant `typescript/` nested directory structure if sources are consolidated. (rm_ts_dir)
- [x] Task: Perform a full dry-run sync to verify runtime stability. (dryrun_pass)
- [ ] Task: Conductor - User Manual Verification 'Cleanup & Verification' (Protocol in workflow.md)
