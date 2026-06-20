# Framework: Recursive Self-Correction

**Objective:** Detect, diagnose, and escape degenerate iteration loops where repeated attempts at the same approach produce no measurable progress — the "doom loop" that is the most common failure mode of autonomous agents.

---

## The Problem

Agents get trapped in fix-forward spirals: a test fails, the agent patches the code, a new test fails, the agent patches again, introducing a third failure, and the cycle continues until the codebase is riddled with band-aid patches on top of band-aid patches. This is the **dominant failure mode** of autonomous coding agents.

---

## Operational Protocol

### 1. Establish the Iteration Ledger

Before beginning any implementation task, initialize an iteration counter in your working memory:

```
ITERATION LEDGER — TASK-XXX
├── Attempt 1: [approach] → [result]
├── Attempt 2: [approach] → [result]
└── Attempt N: [approach] → [result]
```

### 2. After Every Attempt, Update the Ledger

Record:
- What you tried (the specific approach, not just "fixed the bug")
- What happened (exact error, test output, or observation)
- Whether the result is BETTER, SAME, or WORSE than the previous attempt

### 3. Apply the Divergence Detector

After each attempt, evaluate:

| Signal | Meaning | Action |
|--------|---------|--------|
| Error count is decreasing | Converging | Continue current approach |
| Error count is stable | Stalled | Try a fundamentally different approach |
| Error count is increasing | Diverging | **STOP immediately.** Rollback to last known-good state |
| Same error appears 3+ times | Looping | **STOP immediately.** The current mental model is wrong |
| New, unrelated errors appearing | Cascading | **STOP immediately.** Your changes are corrupting adjacent systems |

### 4. The Three-Strike Protocol

If the same approach (or minor variations of it) has failed **3 times**:

1. **STOP** — Do not attempt a 4th variation
2. **REVERT** — `git reset --hard HEAD && git clean -fd`
3. **LOG** — Write a failure entry in `progress_log.md`:
   ```markdown
   ### [timestamp] — FAILURE: Three-Strike Trigger on TASK-XXX
   **Approach tried:** [description]
   **Attempts:** 3
   **Results:** [summary of each attempt's failure]
   **Root cause hypothesis:** [your best guess at WHY this approach keeps failing]
   **Next strategy:** [fundamentally different approach to try]
   ```
4. **RETHINK** — Generate a *fundamentally different* approach. Not a tweak — a different algorithm, architecture, or decomposition
5. **RESTART** — Begin implementation from the clean state with the new approach

### 5. The Escalation Ladder

If the new approach also hits 3 strikes (6 total attempts):

1. **Decompose further** — The task is too large. Break it into smaller sub-tasks
2. **Re-examine assumptions** — Re-read the specification. Verify your understanding of the requirements
3. **Check the environment** — Is the problem in your code, or in the test/build/deploy infrastructure?

If 3 approaches (9 total attempts) all fail:

1. **Flag for human review** — Log the complete iteration ledger and request human input
2. **Do not continue autonomously** — You have exhausted your ability to solve this problem with your current understanding

### 6. The Spiral Detector (Continuous)

Monitor for these real-time signals that you're entering a doom loop:

- [ ] You are editing the same function for the 4th+ time
- [ ] You are adding `try/catch` or `if` guards to suppress errors rather than fix root causes
- [ ] You are modifying test expectations to match broken behavior
- [ ] You are adding parameters or flags to "work around" a design issue
- [ ] Your changes are getting LARGER with each iteration (scope is expanding, not narrowing)
- [ ] You are unsure WHY the previous attempt failed, but you're trying something new anyway

**If any of these are true, STOP and execute the rollback protocol.**

---

## Anti-Rationalization

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "I'm really close, just one more try." | This is the most dangerous statement an agent can make. The iteration ledger, not your optimism, determines whether you are converging. If the data shows stalling or divergence, you are not close. |
| "I understand the problem now, this attempt will be different." | Then articulate the root cause explicitly in the ledger. If you cannot write down what was wrong with your previous approach and why this one is fundamentally different, you are guessing. |
| "Reverting will lose my progress." | If the tests are failing, you have made no progress. Broken code is negative progress. A clean, known-good state is always more valuable than a complex broken state. |
| "The fix is small, I don't need to track it." | Small fixes compound into large disasters. The iteration ledger exists precisely because agents underestimate the cost of "small" changes. |
| "I should fix this failing test first before trying a new approach." | Fixing symptoms (tests) instead of causes (design) is the textbook doom loop. Revert to clean state and address the root cause. |

---

## Evidence Requirement

1. **Iteration Ledger** — A visible record of all attempts, results, and convergence assessments for the current task
2. **No 4th attempt with the same approach** — The git log and progress_log.md must show that after 3 failures, the approach changed fundamentally
3. **Rollback evidence** — When triggered, `git log` must show the revert, not a "fix the fix" commit

---

## Failure Modes

| Failure | Detection | Recovery |
|---------|-----------|----------|
| Agent ignores iteration count | Review git log for >3 commits to same function without green tests | Force revert to last green commit |
| Agent makes superficial approach changes | Compare approaches in ledger — are they truly different or minor variations? | Require explicit justification of how the new approach differs |
| Agent doesn't revert on divergence | Check git diff — is it growing with each iteration? | Force `git reset --hard` to last passing commit |
| Agent modifies tests to pass | Compare test expectations between iterations — did assertions weaken? | Revert test changes, fix implementation instead |
| Agent claims convergence despite evidence | Compare error counts across iterations — are they actually decreasing? | Trust the data, not the agent's narrative |

---

## Integration Points

- **Convergent Iteration (Skill 03):** This skill governs the meta-level monitoring of the iteration loop that Skill 03 operates
- **State Checkpoint Protocol (Skill 04):** All rollbacks use the git-based state machine from Skill 04
- **Strategic Decomposition (Skill 02):** When escalation triggers further decomposition, re-invoke Skill 02
- **Progress Log:** All three-strike events and approach changes are logged for future reference
