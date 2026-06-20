# Agentic Kernel — Quick Reference Card

A one-page operational reference for agents running the kernel.

---

## Phase Flow

```
PLAN → BUILD → VERIFY → PERSIST → (loop)
```

## The 5 Laws (Never Break)

1. **Observable Proof** — Every claim needs evidence
2. **Atomic Transitions** — Never commit broken state
3. **Preserved Intent** — Don't remove what you can't explain
4. **Declared Uncertainty** — Say "I don't know" immediately
5. **Minimal Authority** — Only touch what the task requires

## Per-Task Checklist

```
□ Read PLAN.md, identify next task
□ Write scope declaration
□ Write failing test first
□ Implement (≤50 lines per cycle)
□ Run tests after each change
□ 3-strike check: am I looping?
□ Tests pass → git commit
□ Tests fail → git reset --hard HEAD && git clean -fd
□ Run pentagonal audit (5 axes)
□ Fix any CRITICAL findings
□ Mark task [DONE] in PLAN.md
□ Update progress_log.md
□ Check: need architecture doc update?
□ Check: need context snapshot?
□ Next task
```

## Commit Format

```
<type>(<scope>): TASK-XXX <description>

Types: feat, fix, refactor, test, docs, chore
```

## Error Triage

| Type | Action |
|------|--------|
| Syntax error | Fix immediately |
| Type error | Read function signature first |
| Logic error | Reason before changing |
| Design error | Consider rollback to planning |
| Environment error | Check tooling, not code |

## Convergence Signals

| Signal | Status | Action |
|--------|--------|--------|
| Errors decreasing | ✅ Converging | Continue |
| Errors stable | ⚠️ Stalled | Change approach |
| Errors increasing | 🛑 Diverging | STOP & revert |
| Same error 3x | 🛑 Looping | STOP & rethink |

## The 3-Strike Protocol

```
Strike 1: Attempt fails → Log, try variation
Strike 2: Variation fails → Log, try different variation
Strike 3: Third failure → STOP → REVERT → RETHINK → new approach
```

## Review Axes (Pentagonal Audit)

| Axis | Key Question |
|------|-------------|
| **Correctness** | Edge cases handled? |
| **Readability** | Understandable in 30s? |
| **Architecture** | Boundaries respected? |
| **Security** | Inputs validated? |
| **Performance** | Efficient at scale? |

## File Locations

| File | Purpose |
|------|---------|
| `PLAN.md` | Task checklist |
| `progress_log.md` | Append-only decision log |
| `.docs/architecture/` | System maps |
| `.docs/context/` | Session snapshots |
| `.docs/decisions/` | ADRs |
| `.docs/learned_rules/` | Reusable lessons |

## Task Status Markers

```
[PENDING]           — Not started
[IN PROGRESS]       — Active
[DONE]              — Complete + verified
[BLOCKED:<reason>]  — Waiting on dependency
[REVERTED]          — Attempted, rolled back
```

## Scope Containment

Before coding:
```markdown
## Scope: TASK-XXX
I WILL modify: [files]
I WILL NOT modify: [everything else]
Out-of-scope findings: log to progress_log.md
```

## Navigation Hierarchy

```
1. Architecture docs → broad context
2. Directory listing  → project layout
3. File-level grep   → locate files
4. Symbol search     → locate code
5. Full-text search  → last resort
```

## Context Snapshot Triggers

- Session ending
- Major milestone reached
- Context getting long
- Before risky operations
- After 3+ completed tasks
