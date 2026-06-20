# Strategic Decomposition

**Objective:** Break every distilled specification into a dependency-ordered sequence of small, independently testable vertical slices, output as a concrete PLAN.md file.

---

## Operational Protocol

### Phase 1: Slice Identification

1. **You MUST have a completed specification document** (output of `01_requirement_distillation`) before starting decomposition. If no specification exists, STOP and execute requirement distillation first. Decomposing from a raw user request is prohibited.

2. **You MUST decompose vertically, not horizontally.** Each task delivers a working, testable increment that touches every layer required — from interface to storage, from input to output. The following table clarifies the distinction:

| ✅ Vertical Slice | ❌ Horizontal Slice |
|---|---|
| "Add the `/users` endpoint with validation, DB write, and response — tested end-to-end" | "Create all database models" |
| "Implement login flow: form, auth check, session creation, redirect" | "Build all frontend components" |
| "Parse CSV, validate rows, insert valid rows, return error report" | "Write all validation logic" |

   The test: if a task cannot be demonstrated as a working behavior to a user or verified by a test, it is not a vertical slice. Recut it.

3. **You MUST size every task to complete within approximately 30 minutes of focused agent work.** This includes implementation, testing, and verification. If a task feels larger, apply this splitting heuristic:

   | Signal the Task is Too Large | Splitting Strategy |
   |---|---|
   | More than 5 files likely touched | Split by feature boundary or user-facing behavior |
   | Multiple independent behaviors bundled | One task per behavior |
   | "And" appears in the task title | Each clause becomes its own task |
   | Acceptance criteria have more than 3 GIVEN/WHEN/THEN | One task per criterion or logical group |
   | Task requires both creation and migration of data | Separate creation from migration |

4. **You MUST extract acceptance criteria for each task** from the specification's master acceptance criteria. Every specification criterion must map to at least one task. Any criterion that maps to zero tasks means a task is missing. Any task with no acceptance criterion is unjustified — delete it or justify it.

### Phase 2: Dependency Analysis

5. **You MUST determine actual dependencies between tasks.** A dependency exists ONLY when Task B requires a concrete artifact (file, function, schema, API) produced by Task A. Conceptual ordering ("it makes sense to do A first") is NOT a dependency.

   Apply this dependency verification test to every declared dependency:

   ```
   "If I deleted all code from Task A, would Task B fail to compile, fail its tests,
    or be unable to execute?"
   
   YES → Real dependency. Declare it.
   NO  → Phantom dependency. Remove it.
   ```

6. **You MUST identify the critical path.** The critical path is the longest chain of dependent tasks from start to finish. Mark every task on the critical path with a `🔴 CRITICAL PATH` label. Delays on these tasks delay the entire project. Non-critical tasks have slack and can be reordered.

7. **You MUST order tasks risk-first within dependency constraints.** Among tasks with no unsatisfied dependencies, execute the highest-risk task first. Risk is determined by:

   | Risk Factor | Indicator |
   |---|---|
   | HIGH | Touches unfamiliar code, relies on unverified assumptions, involves external systems, or has no existing test coverage |
   | MEDIUM | Modifies well-understood code but introduces new behavior or changes interfaces |
   | LOW | Adds isolated functionality with clear patterns to follow and existing test infrastructure |

   Rationale: failing fast on high-risk tasks prevents late-stage surprises that cascade through completed work.

### Phase 3: PLAN.md Generation

8. **You MUST produce a PLAN.md file** at the project root (or the designated planning location) with the exact structure defined below. This file is the single source of truth for execution order and progress.

9. **You MUST validate the plan** before finalizing:

   | Validation Check | Pass Criteria |
   |---|---|
   | Complete coverage | Every specification requirement maps to at least one task |
   | No orphan tasks | Every task maps back to at least one specification requirement |
   | No circular dependencies | The dependency graph is a DAG (directed acyclic graph) |
   | No phantom dependencies | Every dependency passes the deletion test (step 5) |
   | Size compliance | No task touches more than 5 files or bundles more than 3 acceptance criteria |
   | Risk-first ordering | Among parallelizable tasks, the highest-risk task has the lowest sequence number |
   | Critical path marked | At least one task chain is identified as the critical path |

10. **You MUST draw a text-based dependency DAG** at the top of the PLAN.md for visual clarity. Use a simple ASCII format:

    ```
    TASK-001 → TASK-003 → TASK-005 🔴
                 ↘
    TASK-002 → TASK-004 → TASK-006
    ```

---

## PLAN.md Output Format

Every strategic decomposition MUST produce a file with exactly this structure:

```markdown
# PLAN: <Project or Feature Title>

**Source Specification:** <link or path to the specification document>
**Generated:** <timestamp>
**Status:** ACTIVE | COMPLETED | SUPERSEDED

## Dependency Graph

<!-- ASCII DAG showing task dependencies and critical path -->

## Task Sequence

### TASK-001: <Concise, verb-first title>
- **Depends on:** None
- **Status:** [PENDING]
- **Critical Path:** Yes / No
- **Risk:** HIGH | MEDIUM | LOW
- **Acceptance Criteria:**
  - GIVEN <precondition> WHEN <action> THEN <outcome>
- **Files likely touched:**
  - `path/to/file.ext`
- **Notes:** <any context, warnings, or implementation hints>

### TASK-002: <Concise, verb-first title>
- **Depends on:** TASK-001
- **Status:** [PENDING]
- **Critical Path:** Yes / No
- **Risk:** HIGH | MEDIUM | LOW
- **Acceptance Criteria:**
  - GIVEN <precondition> WHEN <action> THEN <outcome>
- **Files likely touched:**
  - `path/to/file.ext`
- **Notes:** <any context, warnings, or implementation hints>

<!-- Continue for all tasks -->

## Status Legend
- `[PENDING]` — Not yet started
- `[IN PROGRESS]` — Currently being executed
- `[DONE]` — Completed and verified against acceptance criteria
- `[BLOCKED:<reason>]` — Cannot proceed; reason documented
- `[REVERTED]` — Was completed but rolled back; reason documented

## Revision Log
| Date | Change | Reason |
|---|---|---|
| <date> | Initial plan created | — |
```

---

## Anti-Rationalization Table

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "The project is too small to need a formal plan — I'll just build it." | Small projects are where planning costs the least and disorganization costs the most. A 6-task PLAN.md takes 2 minutes to write and prevents 30 minutes of rework from forgotten edge cases, wrong ordering, or untested paths. Write the plan. |
| "I'll plan as I go — agile means no upfront planning." | Agile means *adaptive* planning, not *absent* planning. Every agile framework begins with a backlog — an ordered list of work. PLAN.md is that backlog. The adaptation happens when you update task statuses and reorder based on discoveries. Create the starting plan. |
| "These tasks all depend on each other so the order is obvious." | If the order is obvious, writing the dependency graph takes sixty seconds. If you are wrong about the dependencies (and agents frequently declare phantom dependencies), the graph exposes the error. Either way, write it. |
| "I need to build the data layer first because everything depends on it." | This is the horizontal slicing anti-pattern. A vertical slice includes *just enough* of the data layer to deliver one testable behavior. Build the full data layer upfront and you have an untestable foundation with no user-visible progress. Slice vertically. |
| "Breaking this into smaller tasks creates overhead — one big task is simpler." | One big task is simpler to *start* and catastrophically harder to *verify, debug, and recover from*. A monolith task that fails at minute 25 wastes all 25 minutes. A small task that fails at minute 5 wastes 5 minutes and leaves all other progress intact. Split it. |
| "I'll add more tasks if I discover them during implementation." | Discovery during implementation is expected — that is why the plan has a Revision Log. But starting without a plan means every discovery is a surprise with no framework to absorb it. The initial plan is the skeleton; discoveries add flesh. Build the skeleton first. |

---

## Evidence Requirement

Execution of this skill is proven by the existence of a **PLAN.md file** that satisfies ALL of the following:

- [ ] Contains a dependency graph (ASCII DAG) at the top
- [ ] Every task has an ID, dependency declaration, status, risk level, and acceptance criteria
- [ ] Every task's acceptance criteria are in GIVEN/WHEN/THEN format with concrete values
- [ ] No task touches more than 5 files
- [ ] The critical path is identified and marked
- [ ] Tasks are ordered risk-first within dependency constraints
- [ ] Every requirement from the source specification maps to at least one task (complete coverage)
- [ ] Every task maps back to at least one specification requirement (no orphans)
- [ ] The dependency graph contains no cycles
- [ ] A Revision Log section exists (even if the initial entry is the only one)
- [ ] All tasks use vertical slicing — each delivers a testable, user-visible or system-verifiable increment

---

## Failure Modes

| # | Failure Mode | Detection | Recovery |
|---|---|---|---|
| 1 | **Analysis paralysis** — excessive time spent refining the plan without beginning execution. The plan exceeds 30 tasks for a feature, or planning takes longer than 15 minutes. | Count the tasks. If there are more than 20 for a single feature, or planning has consumed more than 15 minutes, you are over-planning. | Cap at a reasonable number of tasks. Group related micro-tasks. Begin execution and refine the plan with discoveries via the Revision Log. Imperfect plans executed beat perfect plans in draft. |
| 2 | **Phantom dependencies** — tasks are sequenced by intuition rather than actual compile/runtime dependency, creating an artificially serial execution order. | Apply the deletion test (step 5) to every dependency. If deleting Task A's code would not break Task B, the dependency is phantom. | Remove the phantom dependency. Both tasks can now be considered independent, enabling parallel or reordered execution. |
| 3 | **Monolith tasks** — a task bundles multiple behaviors, touches many files, and cannot be verified atomically. Failure in one part invalidates the entire task. | A task has more than 3 acceptance criteria, touches more than 5 files, or its title contains "and." | Split using the heuristics in step 3. Each sub-task gets its own ID, criteria, and dependency entry. |
| 4 | **Horizontal slicing** — tasks are organized by technical layer (all models, then all services, then all controllers) instead of user-facing behavior. | Review the task list: if any task's acceptance criteria cannot be verified with a running system or a behavioral test, it is a horizontal slice. | Recut the tasks vertically. Each task should deliver one testable behavior end-to-end, including all layers it needs and nothing more. |
| 5 | **Missing coverage** — specification requirements exist that no task addresses, creating silent gaps in the deliverable. | Cross-reference every specification requirement against the task list. Any requirement with zero matching tasks is uncovered. | Create a task for each uncovered requirement. Assign dependencies, risk, and acceptance criteria. Insert into the plan at the correct position. |

---

## Integration Points

| Skill | Relationship |
|---|---|
| `01_requirement_distillation` | The specification document produced by requirement distillation is the **mandatory input** to this skill. Decomposition without a completed spec is prohibited. |
| `test_first_development` | Each task's acceptance criteria feed directly into test case generation. Tests are written before implementation for each task. |
| `task_execution` | PLAN.md is the execution contract. The execution skill picks the next `[PENDING]` task with all dependencies in `[DONE]` status and executes it. |
| `progress_tracking` | Task status markers (`[PENDING]`, `[IN PROGRESS]`, `[DONE]`, `[BLOCKED]`, `[REVERTED]`) are updated by the progress tracking skill after each task completes or fails. |
| `scope_management` | If implementation reveals work not covered by any task, the Revision Log is updated and new tasks are added — but only if they fall within the specification's scope boundaries. Out-of-scope discoveries are logged and deferred. |
