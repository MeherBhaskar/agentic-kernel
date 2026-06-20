# 03 · Convergent Iteration

> **Objective:** Drive code from hypothesis to passing verification through a disciplined Reason-Act-Observe loop with strict divergence detection and hard abort triggers.

---

## 1 · The RAO Loop

Every unit of execution follows this cycle. There are no exceptions.

```
┌──────────┐
│  REASON  │ ← Analyze current state, form hypothesis
└────┬─────┘
     ▼
┌──────────┐
│   ACT    │ ← Write ≤50 lines of code in ONE targeted change
└────┬─────┘
     ▼
┌──────────┐
│ OBSERVE  │ ← Run tests, linter, type-checker. Record results
└────┬─────┘
     ▼
┌──────────┐
│ EVALUATE │ ← Converging or diverging? Continue or abort?
└──────────┘
```

| Phase | You MUST | You MUST NOT |
|-------|----------|--------------|
| **Reason** | State your hypothesis in one sentence before touching code | Jump to editing without a written rationale |
| **Act** | Change ≤50 lines in a single, coherent edit | Scatter changes across unrelated files simultaneously |
| **Observe** | Run the full relevant test/lint suite and record raw output | Eyeball the code and declare it "looks right" |
| **Evaluate** | Compare error count/type against previous iteration | Skip comparison and immediately start the next edit |

---

## 2 · Operational Protocol

1. **Record baseline.** Before your first edit, run the full verification suite. Log the exact error count, error types, and failing test names. This is iteration zero.
2. **State your hypothesis.** Write one sentence: "I believe changing X will fix Y because Z." Do this in your reasoning before every edit.
3. **Make ONE targeted change.** Edit no more than 50 lines. The change MUST directly address your stated hypothesis — nothing else.
4. **Run verification immediately.** Execute tests, linter, and type-checker. Record the new error count and types.
5. **Compare against baseline.** Determine if you are converging (fewer/simpler errors), stable (same errors), or diverging (more errors or new error categories).
6. **Apply the convergence gate:**
   - **Converging →** Continue. Update baseline to current state.
   - **Stable →** Increment the stagnation counter. If stagnation counter ≥ 3, trigger the 3-Strike Rule (§3).
   - **Diverging →** Immediately revert the last change. Re-enter REASON phase with a different hypothesis.
7. **Check iteration budget.** If total iterations for this task exceed the budget (§6), STOP and escalate.
8. **Repeat** from step 2 until all verification passes.

---

## 3 · The 3-Strike Rule

If the same approach (same hypothesis category, same target area) fails three consecutive times:

1. **STOP editing immediately.** Do not attempt a fourth variation.
2. **Revert** to the last known-good state (the baseline from before the three attempts).
3. **Document the failure pattern:** What did you try? Why did it fail each time?
4. **Fundamentally rethink.** The problem is NOT a surface-level code issue — it is an architectural or design misunderstanding. Re-read the relevant code, re-examine assumptions, and formulate a structurally different approach.
5. **If the rethink still produces the same approach**, escalate to the planning phase. You lack information.

> **The 3-Strike Rule is non-negotiable.** A fourth attempt at the same approach is ALWAYS a waste.

---

## 4 · Error Triage Classification

When errors appear, classify them BEFORE attempting a fix:

| Error Class | Examples | Action |
|-------------|----------|--------|
| **Syntax** | Missing semicolons, unclosed brackets, indentation errors | Fix immediately. These are mechanical. |
| **Type** | Wrong argument types, missing fields, incompatible interfaces | Reason about the type relationship before fixing. Often indicates a design misunderstanding. |
| **Logic** | Wrong output, incorrect conditions, off-by-one errors | STOP. Re-read the specification. Trace the logic path manually before editing. |
| **Design** | Circular dependencies, interface mismatches, state management failures | STOP. This likely requires rollback to the planning skill. Do NOT patch around design errors. |
| **Environment** | Missing dependencies, wrong runtime, config issues | Fix the environment, not the code. Verify the fix resolves the error before continuing. |

**Rule:** If you encounter a Design-class error, you MUST NOT attempt to fix it within the iteration loop. Escalate to planning.

---

## 5 · The Spiral Detector

You are in a **fix-spiral** if ANY of the following are true:

| Condition | Detection Method |
|-----------|-----------------|
| >5 consecutive edits to the same function/method | Count edits to the same function across iterations |
| Error count oscillates (goes down, then up, then down) for 3+ cycles | Track error count per iteration; detect oscillation pattern |
| You are reverting your own reverts | You reverted change A, then reverted the revert to try A again |
| New error categories appear after each fix | Track the SET of error types, not just count |
| You are adding workarounds instead of fixing root causes | Your edits contain `if` guards, `try/except` swallowing, or null checks that weren't in your hypothesis |

**When a spiral is detected:**

1. **Revert to the last committed state.** Not the last edit — the last COMMIT.
2. **Re-read the original task specification and all relevant source code.**
3. **Identify the root assumption that is wrong.** Spirals are ALWAYS caused by an incorrect mental model.
4. **Formulate a completely new approach** that does not touch the same function/area.

---

## 6 · Iteration Budget

Every task has an iteration budget. You MUST set this before starting.

| Task Complexity | Max Iterations | Max Time Allocation |
|----------------|----------------|---------------------|
| Trivial (rename, config change) | 3 | 5 minutes |
| Simple (single function, clear spec) | 8 | 15 minutes |
| Medium (multi-file, some ambiguity) | 15 | 30 minutes |
| Complex (architectural, cross-cutting) | 25 | 60 minutes |

**When budget is exceeded:**

1. STOP all editing.
2. Document: what was attempted, what succeeded, what failed, and current state.
3. Commit or revert to a clean state (no half-finished work).
4. Escalate with a clear description of the blocker.

---

## 7 · Anti-Rationalization Table

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "I'll just try one more quick fix — I'm so close." | You said that three iterations ago. The 3-Strike Rule exists because agents ALWAYS think they're close. Revert and rethink. |
| "Reverting would waste all my progress." | Broken code is not progress. A clean state with a better hypothesis IS progress. Sunk cost does not apply to failing code. |
| "I don't need to run tests for such a small change." | Small changes cause large failures. The Observe phase is mandatory for EVERY iteration, regardless of change size. |
| "The error is unrelated to my change — I'll fix it later." | If it appeared after your change, it is related until proven otherwise. Investigate NOW, not later. |
| "I need to change more than 50 lines because these changes are all connected." | If they are connected, they can be sequenced. Break the change into ordered steps of ≤50 lines each. Monolithic changes hide errors. |
| "Running the full test suite takes too long; I'll just run the relevant tests." | You MUST run at minimum all tests in the affected module. Skipping tests is how you enter tunnel-vision fixing — fixing one thing while breaking three others. |

---

## 8 · Evidence Requirement

Execution of this skill is proven by:

- [ ] **Iteration log** showing: iteration number, hypothesis, change summary, verification result, convergence assessment for EACH cycle
- [ ] **Error count trajectory** that trends monotonically downward (with permitted plateaus, no sustained oscillation)
- [ ] **No more than 3 consecutive stable iterations** without a strategy change
- [ ] **Final verification output** showing all tests passing, all lint clean
- [ ] **Total iteration count** within budget

---

## 9 · Failure Modes

| Failure Mode | Detection Signal | Recovery Action |
|---|---|---|
| **Fix-forward spiral** | >5 edits to same function; error count not decreasing | Hard revert to last commit. Re-read task spec. New approach required. |
| **Shotgun debugging** | Changes lack stated hypotheses; edits touch unrelated code areas | STOP. Return to REASON phase. State a hypothesis before ANY edit. |
| **Silent failure acceptance** | Tests pass but output/behavior doesn't match specification | Add assertion tests that check EXACT expected output. Re-read spec line by line. |
| **Tunnel-vision fixing** | Error count stays constant but error identities rotate (fix one, break another) | Revert to last commit. The changes are coupled — you need a unified approach, not sequential patches. |
| **Budget exhaustion without escalation** | Iteration count exceeds budget; agent keeps going | Enforce hard stop. Document state. Escalate. Unbudgeted iteration is uncontrolled iteration. |

---

## 10 · Integration Points

| Skill | Relationship |
|---|---|
| **Task Decomposition** | Provides the tasks that this skill iterates on. Task granularity directly affects iteration budget. |
| **State Checkpoint Protocol** | Convergent iteration produces verified code; checkpointing commits it. Every successful convergence ends with a checkpoint. |
| **Incremental Proof Cycles** | The "Observe" phase of RAO relies on tests defined by proof cycles. No tests = no convergence signal. |
| **Structured Reasoning** | The "Reason" phase of RAO draws on structured reasoning practices. Hypotheses must be explicitly stated, not intuited. |
| **Progress Tracking** | Each iteration's result feeds into progress tracking. Divergence signals feed into risk assessment. |
