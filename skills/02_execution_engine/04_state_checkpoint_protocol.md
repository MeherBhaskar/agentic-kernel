# 04 · State Checkpoint Protocol

> **Objective:** Use version control as a deterministic state machine with binary keep-or-revert discipline after every task completion, ensuring the repository is ALWAYS in a verified, clean state.

---

## 1 · Core Invariant

```
At every moment, HEAD must point to a verified, passing state.
Work-in-progress exists ONLY in the working tree, never in the commit history.
```

The repository has exactly two valid states:

| State | Working Tree | HEAD |
|-------|-------------|------|
| **Idle** | Clean (`git status` shows nothing) | Last verified commit |
| **Active** | Dirty (current task's changes only) | Last verified commit (rollback target) |

Any other state — multiple tasks' changes mixed in the working tree, commits that haven't been verified, dirty tree from a previous task — is a **protocol violation**.

---

## 2 · Operational Protocol

### Phase A: Pre-Task Setup

1. **Verify clean working tree.** Run `git status`. If ANY untracked, modified, or staged files exist, STOP. You MUST resolve the dirty tree before starting:
   - If the changes belong to a previous task: commit them (if verified) or revert them (if not).
   - If the changes are unknown: `git stash` with a descriptive message, then investigate after the current task.
2. **Record the rollback target.** Execute `git rev-parse HEAD` and store the resulting hash. This is your hard-revert target if the task fails.
3. **Assess task uncertainty.** If the task involves experimental or uncertain changes (new library integration, architectural refactor, unfamiliar API):
   - Create an experiment branch: `git checkout -b experiment/<task-id>`
   - This protects the main branch from experimental pollution.
4. **Confirm pre-conditions.** Run the full verification suite. If any tests fail BEFORE you start, you are building on a broken foundation. Fix or report the pre-existing failures first.

### Phase B: During Task Execution

5. **Work exclusively on ONE task.** All changes in the working tree MUST relate to the current task. If you discover an unrelated issue, log it for later — do NOT fix it now.
6. **Do NOT commit intermediate states.** The working tree is your scratch space. Commits are reserved for verified completions only.
7. **If you need to save intermediate progress** (e.g., before an experiment within the task), use `git stash push -m "WIP: <description>"` — never a commit.

### Phase C: The Binary Gate

8. **Run the FULL verification suite.** Tests, linter, type-checker — everything. Not just the tests you think are relevant.
9. **Apply the binary decision:**

```
┌─────────────────────────┐
│  ALL verification passes │
├────────┬────────────────┤
│  YES   │      NO        │
│   ▼    │       ▼        │
│ COMMIT │  HARD REVERT   │
└────────┴────────────────┘
```

   - **PASS → Commit.** Proceed to Phase D.
   - **FAIL → Hard Revert.** Execute: `git reset --hard HEAD && git clean -fd`. Return to the Convergent Iteration skill to reattempt.

> **There is NO middle ground.** You do not commit "mostly working" code. You do not partially revert. The gate is binary.

### Phase D: Atomic Commit

10. **Stage all changes:** `git add -A`
11. **Commit with the prescribed format:**
    ```
    git commit -m "<type>(<scope>): <TASK-ID> <description>"
    ```
12. **Run verification AGAIN on the committed state.** This catches staging errors, missing files, and .gitignore issues.
13. **If post-commit verification fails:** Immediately `git reset --soft HEAD~1`, fix, and return to step 8.

### Phase E: Post-Commit Hygiene

14. **Confirm clean working tree.** `git status` MUST show nothing.
15. **If on an experiment branch and the task succeeded:** Merge back to the working branch: `git checkout <working-branch> && git merge experiment/<task-id> && git branch -d experiment/<task-id>`.
16. **Update progress tracking** with the new commit hash and task completion status.

---

## 3 · Commit Message Format

```
<type>(<scope>): <TASK-ID> <description>
```

| Field | Values | Example |
|-------|--------|---------|
| `type` | `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style` | `feat` |
| `scope` | Module, component, or area affected | `auth`, `api`, `database` |
| `TASK-ID` | The identifier of the task from the task plan | `TASK-003` |
| `description` | Imperative mood, lowercase, no period, ≤72 chars | `add JWT validation middleware` |

**Full example:** `feat(auth): TASK-003 add JWT validation middleware`

**Rules:**
- One commit per task. No exceptions.
- The description MUST describe what was done, not what was attempted.
- Do NOT include phrases like "try to", "attempt to", "WIP", or "partial".

---

## 4 · The Hard Revert

When verification fails, execute the hard revert without hesitation:

```bash
git reset --hard HEAD && git clean -fd
```

| What This Does | Why It's Necessary |
|---|---|
| `git reset --hard HEAD` | Discards ALL staged and unstaged modifications to tracked files | Eliminates partial fixes and half-applied patches |
| `git clean -fd` | Removes ALL untracked files and directories | Eliminates generated files, temp files, and newly created source files from the failed attempt |

**After the hard revert, verify:**
- `git status` shows clean working tree
- `git diff` shows no changes
- The verification suite passes (confirming you're back to the known-good state)

---

## 5 · Branch Strategy

| Scenario | Branch Action |
|----------|--------------|
| Normal task execution | Work directly on the current working branch |
| Experimental/uncertain task | Create `experiment/<task-id>` before starting |
| Multiple competing approaches | Create `experiment/<task-id>-approach-a`, `experiment/<task-id>-approach-b` |
| Experiment succeeds | Merge to working branch, delete experiment branch |
| Experiment fails | Delete experiment branch: `git checkout <working-branch> && git branch -D experiment/<task-id>` |

**Rule:** Experiment branches are disposable. Never develop attachment to them. They exist to be merged or deleted — nothing else.

---

## 6 · Anti-Rationalization Table

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "The code mostly works — I'll commit and fix the remaining issue in the next task." | 'Mostly works' is a euphemism for 'broken.' HEAD must ALWAYS point to a fully verified state. Commit broken code and every subsequent task builds on a cracked foundation. |
| "Reverting will lose good work. Let me salvage the parts that work." | Partial reverts create chimeric states that are harder to debug than a clean start. The hard revert is fast; re-implementing the good parts with a correct approach is faster than debugging a partial salvage. |
| "I'll commit now and write the tests in the next task." | Untested commits are unverified commits. An unverified commit violates the core invariant. Write the tests, verify, THEN commit — all in one atomic unit. |
| "I have changes from the last task I forgot to commit. I'll just include them with this task's commit." | One task, one commit. Batching changes from multiple tasks makes bisection, revert, and understanding impossible. Commit the old changes separately first (if they pass), or revert them. |
| "Creating an experiment branch is overhead for such a simple change." | Simple changes that go wrong contaminate the main branch. The cost of `git checkout -b` is two seconds. The cost of debugging a contaminated main branch is unbounded. |

---

## 7 · Evidence Requirement

Execution of this skill is proven by:

- [ ] **Clean `git status`** before starting the task (screenshot or log output)
- [ ] **Recorded rollback target** (HEAD hash logged before work began)
- [ ] **Single atomic commit** per completed task with correct message format
- [ ] **Post-commit verification** passing (test suite output after the commit)
- [ ] **No commits with "WIP", "fixup", "temp", or "TODO" in the message**
- [ ] **Git log** showing a linear sequence of verified, atomic commits

---

## 8 · Failure Modes

| Failure Mode | Detection Signal | Recovery Action |
|---|---|---|
| **Commit hoarding** | `git log` shows no commits across multiple completed tasks; working tree has changes spanning multiple features | Stop. Separate the changes by task. Verify each independently. Commit them as separate, ordered commits. If separation is impossible, hard revert and redo tasks one at a time. |
| **Partial revert** | `git diff` after "reverting" still shows some changes from the failed attempt | Execute the full hard revert: `git reset --hard HEAD && git clean -fd`. Verify with `git status` AND `git diff`. Partial reverts are not reverts. |
| **Dirty-tree continuation** | `git status` shows modifications when starting a new task | STOP. Do not start the new task. Resolve the existing changes first: commit if verified, revert if not, stash if uncertain. |
| **Broken HEAD** | Running the verification suite at HEAD (without any local changes) produces failures | The core invariant is violated. Identify the bad commit with `git log` and `git bisect`. Revert it. All work built on a broken HEAD is suspect and must be re-verified. |
| **Experiment branch abandonment** | Stale `experiment/*` branches accumulate in the repository | Audit experiment branches regularly. Delete any that are >1 task old. Merge or discard — no branch hoarding. |

---

## 9 · Decision Flowchart

```
START NEW TASK
      │
      ▼
  git status clean? ──NO──► Resolve dirty tree FIRST
      │
     YES
      │
      ▼
  Record HEAD hash (rollback target)
      │
      ▼
  Task uncertain? ──YES──► git checkout -b experiment/<task-id>
      │
      NO
      │
      ▼
  Execute task (Convergent Iteration skill)
      │
      ▼
  Run FULL verification
      │
      ▼
  All pass? ──NO──► git reset --hard HEAD && git clean -fd
      │                    │
     YES                   ▼
      │              Return to Convergent Iteration
      ▼
  git add -A && git commit -m "<format>"
      │
      ▼
  Run verification AGAIN
      │
      ▼
  All pass? ──NO──► git reset --soft HEAD~1, fix, retry
      │
     YES
      │
      ▼
  Confirm git status clean
      │
      ▼
  TASK COMPLETE
```

---

## 10 · Integration Points

| Skill | Relationship |
|---|---|
| **Convergent Iteration** | Produces the verified code that this skill commits. A successful convergence triggers the binary gate in this skill. A failed convergence triggers the hard revert. |
| **Incremental Proof Cycles** | Provides the tests that the binary gate runs. Without tests, the gate has no verification signal and the commit is unverified. |
| **Task Decomposition** | Defines task boundaries that map 1:1 to commits. Poorly decomposed tasks produce bloated commits or commit hoarding. |
| **Progress Tracking** | Each commit/revert event is a progress tracking data point. Commit hashes anchor the progress log to verifiable repository states. |
| **Context Management** | Clean commits and clear messages make context reconstruction possible. Sloppy commit history degrades the agent's ability to understand past decisions. |
