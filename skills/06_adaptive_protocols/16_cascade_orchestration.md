# Framework: Cascade Orchestration

**Objective:** Coordinate multi-phase, multi-step workflows where the output of one skill feeds into the input of another — enabling the agent to operate as a self-directed pipeline rather than requiring human orchestration between phases.

---

## The Problem

Individual skills are powerful but isolated. Without orchestration:
- Agents complete Phase 1 (planning) but forget to transition to Phase 2 (execution)
- Phase outputs aren't properly formatted for the next phase's input
- Errors in one phase cascade silently into subsequent phases
- The agent loses track of where it is in the overall workflow

Cascade Orchestration is the "conductor" that ensures the full loop executes correctly.

---

## Operational Protocol

### 1. Initialize the Cascade

At the start of any task, create the cascade state tracker:

```markdown
## Cascade State — [Task/Feature Name]
**Initiated:** [timestamp]
**Current Phase:** 1 — Mission Synthesis
**Phase Progress:**
- [ ] Phase 1: Mission Synthesis
  - [ ] 1.1: Requirement Distillation → SPEC.md
  - [ ] 1.2: Strategic Decomposition → PLAN.md
- [ ] Phase 2: Execution Engine (per task in PLAN.md)
  - [ ] 2.1: Convergent Iteration
  - [ ] 2.2: State Checkpoint
  - [ ] 2.3: Incremental Proof Cycle
- [ ] Phase 3: Verification Matrix
  - [ ] 3.1: Pentagonal Audit
  - [ ] 3.2: Entropy Reduction (if applicable)
- [ ] Phase 4: Cognitive Persistence
  - [ ] 4.1: Structural Cartography update
  - [ ] 4.2: Context Lifecycle snapshot
```

### 2. Phase Transition Gates

A phase transition is ONLY valid when ALL exit criteria for the current phase are met:

| Phase | Exit Criteria | Output Artifact |
|-------|--------------|-----------------|
| 1 → 2 | PLAN.md exists with ≥1 task marked `[IN PROGRESS]` AND spec has acceptance criteria | `PLAN.md`, specification in `progress_log.md` |
| 2 → 3 | Current task implementation is complete AND tests pass | Committed code, passing test output |
| 3 → 2 | Review summary logged AND all CRITICAL findings resolved | Review entry in `progress_log.md` |
| 3 → 4 | All tasks in PLAN.md are `[DONE]` AND final review passed | Clean `git status`, all tests passing |
| 4 → 1 | Knowledge artifacts updated AND context snapshot written | Updated `.docs/`, snapshot file |

### 3. The Inner Loop (Per-Task Cycle)

For each task in `PLAN.md`, execute this inner loop:

```
┌──────────────────────────────────────────────────────────────┐
│ For each TASK in PLAN.md:                                     │
│                                                               │
│  1. Mark task [IN PROGRESS]                                   │
│  2. Execute Skill 05 (Incremental Proof) → write failing test │
│  3. Execute Skill 03 (Convergent Iteration) → implement       │
│     ├── On convergence → continue                             │
│     └── On divergence → Skill 13 (Self-Correction) → rollback│
│  4. Execute Skill 04 (State Checkpoint) → commit or revert   │
│     ├── On commit → continue to review                        │
│     └── On revert → return to step 2 with new approach       │
│  5. Execute Skill 06 (Pentagonal Audit) → review              │
│     ├── All clear → mark task [DONE], next task               │
│     └── CRITICAL findings → fix, re-commit, re-review        │
│                                                               │
│  Monitor: Skill 13 (Self-Correction) active throughout       │
│  Monitor: Skill 14 (Scope Containment) active throughout     │
└──────────────────────────────────────────────────────────────┘
```

### 4. The Outer Loop (Cross-Task Progression)

After each task completes:

1. **Update PLAN.md** — Mark the task `[DONE]`, check for newly unblocked tasks
2. **Check dependencies** — Ensure the next task's prerequisites are met
3. **Checkpoint** — If 3+ tasks are complete since the last snapshot, write a context snapshot (Skill 09)
4. **Update architecture** — If any structural changes were made, update `.docs/architecture/` (Skill 08)
5. **Consolidate** — If any notable failures or learnings occurred, run experiential consolidation (Skill 15)
6. **Select next task** — Pick the highest-priority unblocked task from PLAN.md

### 5. Cascade Completion

The cascade is complete when:
- [ ] All tasks in PLAN.md are marked `[DONE]`
- [ ] The full test suite passes
- [ ] A final pentagonal audit has been performed on the complete changeset
- [ ] Architecture docs are updated
- [ ] A completion context snapshot is written
- [ ] All deferred observations from Skill 14 have been logged as future tasks

### 6. Cascade Failure & Recovery

If the cascade stalls (no progress for 3+ inner-loop iterations):

1. **Pause** — Stop the current task
2. **Write emergency snapshot** — Capture the exact cascade state
3. **Diagnose** — Is the stall in planning, execution, or review?
4. **Escalate** — If planning: re-decompose. If execution: try different approach. If review: lower severity threshold and re-assess
5. **Resume** — From the diagnosed point, not from the beginning

---

## Anti-Rationalization

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "I'll skip the review phase since the code is straightforward." | The review phase exists precisely for code you believe is straightforward. Overconfidence is the input; review is the correction. |
| "I don't need a plan for this small feature." | The cascade starts at Phase 1 regardless of feature size. Small features have small plans. The plan still gets written. |
| "I'll update the architecture docs at the end." | Architecture docs updated at the end are aspirational documentation. Update them as structural changes happen, or they will never be accurate. |
| "I'll combine phases 2 and 3 to save time." | Combining implementation and review in the same mental pass reduces review quality to zero. They must be separate cognitive acts. |
| "The inner loop is too slow for simple bug fixes." | For simple bug fixes, each step takes seconds. The discipline is the same regardless of task size. Speed comes from practice, not from skipping steps. |

---

## Evidence Requirement

1. **Cascade state tracker** — A visible record of phase progression exists for the current work
2. **Phase gates respected** — No phase was entered without the previous phase's exit criteria being met
3. **Inner loop evidence** — Each task has: failing test → passing implementation → commit → review entry
4. **Completion checklist** — All completion criteria are checked off before the cascade is declared done

---

## Failure Modes

| Failure | Detection | Recovery |
|---------|-----------|----------|
| Phase skipped | Cascade tracker shows unchecked phases | Return to the skipped phase and complete it |
| Inner loop abandoned mid-task | Task is `[IN PROGRESS]` but no recent activity | Resume from last checkpoint or revert |
| Cascade stalls silently | No PLAN.md updates for extended period | Write emergency snapshot, diagnose stall point |
| Over-orchestration | Agent spends more time on cascade bookkeeping than actual work | Simplify the tracker, keep it lightweight |
| Cascade never completes | Tasks keep getting added faster than completed | Freeze scope, complete existing tasks before adding new ones |

---

## Integration Points

- **All skills** — This skill orchestrates the execution of every other skill in the system
- **SYSTEM_CORE.md** — The cascade implements the operational state machine defined in the apex kernel
- **PLAN.md** — The primary data structure driving the cascade's inner and outer loops
- **progress_log.md** — The append-only audit trail of cascade execution
