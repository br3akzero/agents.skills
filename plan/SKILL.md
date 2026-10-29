---
name: plan
description: Plan a feature as vertical slices. Each slice is one concern completed end-to-end (config + impl + tests + build verify). Use when starting new feature work or when user says "plan" or "vertical slice".
---

# Vertical Slice Planning

Plan feature work as vertical slices. Each slice completes one concern end-to-end before
moving to the next.

## Rules

1. **One concern per slice.** A slice is: config + implementation + tests + build verify.
2. **Never bundle.** If two concerns share a file, they still get separate slices.
3. **Testable output.** Every slice must produce something independently testable.
4. **Chronological order.** Slices follow the data flow, not the layer cake.
5. **No horizontal layers.** Never do "all config, then all repos, then all use cases."
6. **Ask one question at a time** when probing design decisions. Provide recommendations.

## Bad (Horizontal)

```
1. All config (S3, Redis, OCR, Invoice)
2. All repos
3. All pkg clients
4. All use cases
```

## Good (Vertical)

```
1. S3 integration: config + pkg/s3 + MinIO + tests
2. Asynq integration: config + pkg/asynq + Redis + tests
3. Invoice repo: contracts + impl + tests
4. Upload flow: use cases + handlers + routes + wiring
```

## Planning Structure

```
.agents/plans/{feature}/
  plan.md          — architecture, decisions, phase index (map of all work)
  phases/
    phase-1.md     — vertical slice detail (steps, files, tests)
    phase-2.md     — next vertical slice
```

### plan.md Contains

- Goal and context (issue links, dependencies)
- Pipeline/architecture diagram
- Architecture decisions table
- DB schema (if applicable)
- Phase index table (phase number, sub-issue, status, delivers)
- Implementation rules
- Out of scope list

**plan.md is the index, not the detail.**

### phase-N.md Contains

- Overview (1-2 sentences)
- Dependencies (which phases must be done)
- Ordered steps with:
  - File path to create/modify
  - Struct/interface signatures
  - Logic description (not full code)
- Files created / files modified lists
- Test plan
- Build verify command

## Execution Rules

- Create todos from the phase steps before starting
- One step at a time. Review after each step. Do not bulk.
- Commit after each completed slice (or group of related steps within a slice)
- Build verify after each slice
- Move to next slice only after current slice passes build + tests

## When to Use

- User starts new feature work
- User says "plan", "vertical slice", or "plan this feature"
- Planning a multi-step implementation across packages/layers
