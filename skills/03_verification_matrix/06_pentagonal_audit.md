# Pentagonal Audit

## Objective

Every code change MUST pass a structured review across five mandatory axes — Correctness, Readability, Architecture, Security, and Performance — before it is considered commit-ready.

---

## The Five Axes

| # | Axis | Core Question | Key Concerns |
|---|------|---------------|--------------|
| 1 | **Correctness** | Does this code do what it claims under all conditions? | Edge cases, boundary conditions, null/empty inputs, error propagation, off-by-one errors, race conditions, type coercion traps |
| 2 | **Readability** | Can a stranger understand this code in under 60 seconds? | Self-documenting names, obvious control flow, comments explain *why* not *what*, consistent style, no abbreviation puzzles |
| 3 | **Architecture** | Does this change respect the system's structural contracts? | Module boundaries, established patterns, coupling avoidance, single responsibility, dependency direction, layer violations |
| 4 | **Security** | Can this code be weaponized by a hostile input? | Input validation, no hardcoded secrets, injection prevention (SQL, XSS, path traversal, command injection), auth/authz checks, data exposure |
| 5 | **Performance** | Will this code degrade under realistic load? | N+1 queries, nested loops over large datasets, inappropriate data structures, unnecessary allocations, missing indices, unbounded collections |

---

## Operational Protocol

1. **You MUST complete the pentagonal audit after every functional code change and before declaring any task complete.** No exceptions for "trivial" changes.
2. **Generate the diff.** Produce or retrieve the exact set of lines changed. The review operates on the diff, not the entire file.
3. **Apply the diff-only rule.** Review only changed lines plus ±10 lines of surrounding context. Do NOT get drawn into reviewing unrelated code. If you spot issues elsewhere, log them as separate backlog items — do not fix them now.
4. **Walk each axis sequentially.** For every axis, produce one of the following:
   - A concrete finding with severity classification.
   - An explicit `No issues found` declaration. You MUST NOT skip an axis or leave it blank.
5. **Classify every finding by severity:**

   | Severity | Definition | Required Action |
   |----------|-----------|-----------------|
   | **CRITICAL** | Breaks correctness, introduces a vulnerability, or violates an architectural invariant | MUST fix before commit. No exceptions. |
   | **WARNING** | Degrades quality but does not break functionality | SHOULD fix before commit. Document justification if deferred. |
   | **INFO** | Optional improvement, stylistic suggestion | MAY fix. No blocking. |

6. **Record the review output.** Append a structured review block to `progress_log.md` using this exact format:

   ```markdown
   ## Pentagonal Audit: TASK-XXX
   **Timestamp:** YYYY-MM-DD HH:MM
   **Files reviewed:** [list of files]
   **Diff scope:** [number of lines added/removed]

   | Axis | Finding | Severity | Action Taken |
   |------|---------|----------|--------------|
   | Correctness | [finding or "No issues found"] | [severity or N/A] | [fix applied / deferred / N/A] |
   | Readability | ... | ... | ... |
   | Architecture | ... | ... | ... |
   | Security | ... | ... | ... |
   | Performance | ... | ... | ... |

   **CRITICAL count:** X | **WARNING count:** Y | **INFO count:** Z
   **Verdict:** PASS / FAIL (FAIL if any CRITICAL remains unresolved)
   ```

7. **Fix all CRITICAL findings.** Apply the fix, then proceed to Step 8.
8. **Execute the second-pass rule.** After fixing any CRITICAL finding, re-run the pentagonal audit on the fix itself. A fix that introduces a new CRITICAL is not a fix. This recursion terminates when a pass produces zero CRITICALs.
9. **Take the 'fresh eyes' perspective.** Review your own diff as if you are reviewing a stranger's code. Assume the author made mistakes. Actively search for flaws rather than confirming correctness.
10. **Declare verdict.** A commit is PASS only when all five axes are addressed and zero CRITICAL findings remain open.

---

## Axis Deep-Dive Checklists

### Axis 1: Correctness
- [ ] All conditional branches have been mentally traced with boundary inputs
- [ ] Null, empty, zero, negative, and maximum-value inputs are handled
- [ ] Error cases propagate or are handled — no silent swallowing
- [ ] Loop bounds are correct (no off-by-one on indices, ranges, or slices)
- [ ] Concurrent access points are protected or documented as single-threaded
- [ ] Type conversions are explicit and safe (no silent truncation or coercion)
- [ ] Return values from fallible operations are checked

### Axis 2: Readability
- [ ] Variable and function names describe purpose, not implementation
- [ ] Control flow is linear where possible (early returns over deep nesting)
- [ ] Comments explain *why*, not *what* — the code explains *what*
- [ ] No magic numbers or strings — all are named constants
- [ ] Consistent formatting with the surrounding codebase
- [ ] Functions are ≤40 lines; if longer, justify or extract

### Axis 3: Architecture
- [ ] Change respects module boundaries — no reaching across layers
- [ ] New dependencies point in the correct direction (inward, not outward)
- [ ] No circular dependencies introduced
- [ ] Single responsibility — each function/class does one thing
- [ ] Follows patterns already established in the codebase (no novel patterns without justification)
- [ ] Public API surface is minimal — no unnecessary exports

### Axis 4: Security
- [ ] All external inputs are validated before use
- [ ] No secrets, keys, or credentials in source code
- [ ] SQL queries use parameterized statements, never string concatenation
- [ ] HTML output is escaped to prevent XSS
- [ ] File paths are sanitized against traversal attacks (`../`)
- [ ] Authentication and authorization checks are present on protected operations
- [ ] Sensitive data is not logged or exposed in error messages

### Axis 5: Performance
- [ ] No N+1 query patterns (query inside a loop)
- [ ] No nested iteration over large or unbounded collections
- [ ] Data structures are appropriate for the access pattern (map vs. list, set vs. array)
- [ ] No unnecessary object allocations in hot paths
- [ ] Database queries use appropriate indices
- [ ] No synchronous blocking of async contexts
- [ ] Results that are expensive to compute are cached when reused

---

## Anti-Rationalization Table

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "This change is trivial — a one-line fix doesn't need a full review." | One-line changes have caused production outages at every major tech company. The pentagonal audit takes 2 minutes on a small diff. Skipping it to save 2 minutes risks hours of debugging. Run the audit. |
| "I already reviewed it mentally while writing the code." | Writing and reviewing are cognitively different activities. The author's brain fills in intent where the code has gaps. The 'fresh eyes' rule exists because self-deception is the default, not the exception. Record the audit. |
| "The tests pass, so correctness is proven." | Tests prove the cases they cover. The Correctness axis specifically targets cases tests might miss: edge cases, race conditions, error propagation paths. Passing tests are necessary but not sufficient. Check the axis. |
| "Security doesn't apply — this is internal code." | Internal code becomes external code through API exposure, dependency chains, and lateral movement after compromise. Every input boundary is a security boundary. Validate the axis. |
| "I'll review it later / in the next pass." | Deferred reviews are abandoned reviews. The cost of fixing a defect rises exponentially with time since introduction. The audit happens now, on this diff, before this commit. No deferral. |
| "Reviewing my own code is pointless — I need a human reviewer." | You are the first line of defense, not the last. Self-review catches 60-80% of defects that would otherwise waste a human reviewer's time. The pentagonal audit is your professional obligation before requesting external review. |

---

## Evidence Requirement

A correctly executed pentagonal audit produces the following verifiable artifacts:

1. **A completed review block in `progress_log.md`** matching the exact format in Step 6, with all five axes populated.
2. **Zero open CRITICAL findings** in the final verdict.
3. **Second-pass entries** for every CRITICAL that was fixed — proving the fix was itself reviewed.
4. **A PASS verdict** explicitly recorded.

If any of these artifacts are missing, the audit was not executed.

---

## Failure Modes

| # | Failure Mode | Detection Signal | Recovery Action |
|---|---|---|---|
| 1 | **Rubber-stamp review** — All axes marked "No issues found" on a non-trivial diff | A diff with >20 changed lines that produces zero findings across all five axes is statistically implausible. | Re-run the audit with deliberate adversarial thinking. Ask: "If I were trying to break this code, where would I attack?" |
| 2 | **Scope creep** — Review expands to unrelated code, triggering unplanned refactoring | Review touches files not in the original diff. Time spent exceeds 5× the expected review duration. | Stop immediately. Log unrelated findings as backlog items. Return to the diff-only rule. |
| 3 | **Perfectionism paralysis** — Blocking on stylistic preferences that don't affect correctness | Multiple WARNING/INFO findings on naming or formatting with no CRITICAL findings, and the commit is delayed. | Apply the severity hierarchy. INFO findings are optional. WARNING findings can be deferred with documented justification. Ship. |
| 4 | **Second-pass infinite loop** — Fix introduces new CRITICAL, fix for that introduces another | More than 3 recursive second-pass cycles on the same change. | Stop and reassess the approach. The change is likely fundamentally flawed. Revert to last known good state and redesign. |
| 5 | **Axis conflation** — Mixing concerns across axes (e.g., reporting a performance issue under Architecture) | Findings appear under incorrect axis headers. | Each axis has a defined scope. Re-classify the finding under the correct axis. Misclassification obscures patterns in historical data. |

---

## Integration Points

| Skill | Integration |
|---|---|
| **Test-First Verification** | The Correctness axis validates that test coverage exists for changed code. If tests are missing, the Correctness axis produces a CRITICAL finding. |
| **Entropy Reduction** | Readability and Architecture axis findings often surface simplification opportunities. Log these as inputs to the entropy reduction protocol. |
| **Progress Logging** | The review block is appended directly to `progress_log.md`, creating a persistent audit trail for every commit. |
| **Pre-Commit Verification** | The pentagonal audit is a prerequisite gate. No commit proceeds without a PASS verdict. |
| **Specification Adherence** | The Correctness axis cross-references the task specification to verify that changed behavior matches stated requirements. |
| **Dependency Analysis** | The Architecture axis validates that new dependencies follow established dependency direction rules and do not introduce cycles. |
