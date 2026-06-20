# Framework: Scope Containment Discipline

**Objective:** Prevent the autonomous expansion of task scope that occurs when agents encounter related problems, interesting code, or "while I'm here" opportunities during implementation — the second most common failure mode after doom loops.

---

## The Problem

Agents are trained to be helpful. When they see a TODO comment, a deprecated function, or a slightly suboptimal pattern adjacent to their current task, they feel compelled to fix it. This is catastrophic because:

1. **Untested changes** — Adjacent "improvements" are made without corresponding test updates
2. **Review contamination** — The diff now contains changes unrelated to the task, making review impossible
3. **Rollback destruction** — If the task fails and must be reverted, the "bonus" improvements are lost too
4. **Scope compound interest** — Each side-fix reveals more side-fixes, creating unbounded work

---

## Operational Protocol

### 1. Define the Scope Boundary Before Starting

Before writing any code for a task, explicitly state:

```markdown
## Scope Declaration — TASK-XXX
**I WILL modify:** [list of specific files/functions/modules]
**I WILL NOT modify:** [anything not listed above]
**If I discover an issue outside scope:** Log it in `progress_log.md` under "DEFERRED OBSERVATIONS" and continue with the current task.
```

### 2. The Touch Audit

After completing implementation but before committing, run a diff and verify:

```bash
git diff --stat
```

For EVERY file in the diff:
- [ ] Is this file listed in my scope declaration?
- [ ] If not, is the change absolutely necessary for my task to work? (e.g., import added, type signature changed)
- [ ] If neither, **revert the change** to that file immediately

### 3. The Deferred Observation Log

When you encounter something that should be fixed but is outside your current scope:

```markdown
### [timestamp] — DEFERRED: [Brief description]
**Location:** `path/to/file.ext:L42`
**Observation:** [What you noticed]
**Recommended action:** [What should be done]
**Priority:** LOW | MEDIUM | HIGH
**Reason for deferral:** Outside scope of TASK-XXX
```

This is NOT laziness — this is **discipline**. The observation is captured. It will be addressed. But not now, not in this commit.

### 4. The Scope Creep Detector

Monitor for these real-time signals that scope is expanding:

| Signal | Detection | Action |
|--------|-----------|--------|
| You're editing a file not in your scope declaration | `git diff --stat` shows unexpected files | Revert changes to out-of-scope files |
| Your task description has grown since you started | Compare current understanding to PLAN.md | Return to original scope |
| You're spending >20% of time on "related" improvements | Self-assessment | Log deferred observations, refocus |
| Your commit message needs "also" or "additionally" | Writing the commit message | Split into separate commits/tasks |
| The diff is >3x the expected size | `git diff --stat` line count | Review what's in scope vs. out |

### 5. The Refactoring Quarantine

If you discover that your task CANNOT be completed without modifying out-of-scope code:

1. **STOP** — Do not start the out-of-scope modification
2. **DOCUMENT** — Log why the scope expansion is necessary
3. **ISOLATE** — Create a SEPARATE task in PLAN.md for the prerequisite work
4. **SEQUENCE** — Complete the prerequisite task first, commit it separately, then return to the original task
5. **NEVER** bundle prerequisite refactoring and feature work in the same commit

---

## Anti-Rationalization

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "While I'm in this file, I might as well fix this too." | You are not in this file to fix other things. Every unscoped change is an untested change. Log it and move on. |
| "This refactoring is necessary for my change to work." | Then it is a separate prerequisite task. Create a new task, complete it with its own tests and commit, then return to your original task. |
| "It's just a one-line change, it won't break anything." | The commit history of every failed project is full of "one-line changes that won't break anything." Scope discipline applies to all changes, regardless of size. |
| "The code reviewer will appreciate me cleaning this up." | The code reviewer will appreciate a focused, reviewable diff far more than a sprawling commit that mixes feature work with opportunistic cleanup. |
| "I'll add a test for this bonus change too." | Now you're spending time writing tests for unscoped work instead of completing your actual task. The priority queue exists for a reason. |
| "Leaving this unfixed feels wrong." | Discipline often feels uncomfortable. That discomfort is the feeling of professional rigor. Log the observation and continue. |

---

## Evidence Requirement

1. **Scope Declaration** — A written scope boundary exists for the current task before implementation begins
2. **Clean Diff** — `git diff --stat` shows only files listed in the scope declaration (plus necessary imports/signatures)
3. **Deferred Log** — Any out-of-scope observations are logged, not silently acted upon
4. **Atomic Commits** — Each commit addresses exactly one task. No "also fixed X" in commit messages

---

## Failure Modes

| Failure | Detection | Recovery |
|---------|-----------|----------|
| Scope declaration not written | No scope boundary in progress_log.md for current task | Write it before proceeding |
| Out-of-scope files modified | `git diff --stat` shows unexpected files | `git checkout -- <file>` for each out-of-scope file |
| Prerequisite work bundled with feature | Commit message describes multiple unrelated changes | Split into separate commits via `git reset HEAD~1` and selective staging |
| Deferred observations not logged | Agent fixed adjacent issues without documentation | Review diff, revert unscoped changes, log as deferred |
| Scope gradually expanded without acknowledgment | Task took 3x longer than estimated with no scope change logged | Review progress_log.md, identify scope drift points |

---

## Integration Points

- **Strategic Decomposition (Skill 02):** Scope boundaries are derived from the task definitions in PLAN.md
- **State Checkpoint Protocol (Skill 04):** The touch audit happens before every commit
- **Pentagonal Audit (Skill 06):** The review includes verifying that the diff only touches scoped files
- **Progress Log:** All deferred observations are logged for future task creation
