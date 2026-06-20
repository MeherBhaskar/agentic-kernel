# Entropy Reduction

## Objective

Every simplification MUST preserve exact observable behavior, proven through characterization tests, while measurably reducing cyclomatic complexity, line count, or cognitive load.

---

## Governing Laws

| Law | Statement | Implication for Simplification |
|-----|-----------|-------------------------------|
| **Principle of Preserved Intent** | Never remove something until you understand why it was put there. | You MUST articulate the original purpose of any code you intend to remove. If you cannot explain why it exists, you cannot remove it. |
| **Law of Implicit Dependency** | Every observable behavior of your system will be depended on by someone. | Even "internal" behaviors may have external dependents. Changing behavior — even behavior you consider incidental — is a breaking change until proven otherwise. |
| **Second Law of Thermodynamics** | Entropy increases unless energy is deliberately applied to reduce it. | Codebases do not simplify themselves. Complexity reduction requires intentional, disciplined effort with every change. |

---

## The Complexity Budget

Every code unit MUST respect these hard limits. Violations are CRITICAL findings.

| Scope | Metric | Budget | Measurement |
|-------|--------|--------|-------------|
| Function | Cyclomatic complexity | ≤ 10 | Count decision points: `if`, `else if`, `for`, `while`, `case`, `catch`, `&&`, `\|\|`, `?:` |
| Function | Line count | ≤ 40 | Excluding blank lines and comments |
| File | Line count | ≤ 300 | Total lines including all content |
| Class | Public methods | ≤ 7 | Count of public-facing methods (excluding constructors and standard interface implementations) |
| Function | Parameters | ≤ 4 | Count of function parameters (use an options/config object beyond 4) |
| Nesting | Depth | ≤ 3 | Maximum nesting depth of control structures |

---

## Operational Protocol

### Phase 1: Measure Before You Cut

1. **Identify the target.** Select the function, class, or module to simplify. You MUST have a concrete reason — a complexity budget violation, a readability complaint, or a bug in the area.
2. **Record baseline metrics.** Before any change, measure and document:
   - Cyclomatic complexity of each target function
   - Line count of the target file
   - Number of public methods (if class)
   - Nesting depth of deepest block
3. **Articulate the purpose of every code block you intend to modify.** For each block, answer: *"Why was this written this way?"* If you cannot answer, STOP. Research the history (git blame, commit messages, related tests, comments) until you can. This is the Principle of Preserved Intent — you do not pass until you understand.

### Phase 2: Characterize Current Behavior

4. **Write characterization tests.** Before simplifying, write tests that capture the *current* behavior of the code — including edge cases, error paths, and any behavior you suspect might be incidental but depended upon.
5. **Characterization test requirements:**
   - Cover every branch in the target code
   - Include at least one test per: happy path, error path, boundary value, null/empty input
   - Tests MUST assert on actual current behavior, not desired behavior
   - Tests MUST pass against the unmodified code before you proceed
6. **Run all characterization tests.** Confirm green. If any test fails against unmodified code, your characterization is wrong. Fix the test, not the code.

### Phase 3: Simplify

7. **Apply simplification techniques from the refactoring catalog** (see below). Make one transformation at a time. Do NOT batch multiple refactorings into a single change.
8. **After each transformation, run all characterization tests.** If any test fails:
   - You have changed observable behavior.
   - Revert the transformation.
   - Analyze why the behavior changed.
   - Either adjust your approach or document why the behavior change is intentional and safe.
9. **You MUST NOT modify characterization tests to make them pass.** If a characterization test fails after simplification, that is a signal that behavior changed — not that the test is wrong. Modifying tests to match new behavior masks regressions.

### Phase 4: Verify and Record

10. **Run the full existing test suite** (not just characterization tests). All tests MUST pass.
11. **Record post-simplification metrics.** Measure the same metrics from Step 2.
12. **Produce a complexity delta report** in `progress_log.md`:

    ```markdown
    ## Entropy Reduction: TASK-XXX
    **Timestamp:** YYYY-MM-DD HH:MM
    **Target:** [function/class/module name]
    **Reason for simplification:** [concrete reason]

    | Metric | Before | After | Delta |
    |--------|--------|-------|-------|
    | Cyclomatic complexity | X | Y | -Z |
    | Line count | X | Y | -Z |
    | Nesting depth | X | Y | -Z |
    | Public methods | X | Y | -Z |

    **Techniques applied:** [list from refactoring catalog]
    **Characterization tests written:** [count]
    **Behavior changes:** None / [documented intentional changes with justification]
    **Verdict:** PASS (complexity reduced, behavior preserved)
    ```

13. **Dispose of redundant characterization tests.** If existing tests in the suite already cover the same behavior as your characterization tests, remove the characterization tests. If they cover behavior not tested elsewhere, promote them to permanent tests.

---

## Refactoring Catalog

Apply these techniques. Each has a precondition and a verification step.

| # | Technique | When to Apply | Precondition | Verification |
|---|-----------|--------------|--------------|-------------|
| 1 | **Extract Method** | A code block within a function serves a distinct purpose | Block is ≥5 lines and has a clear single responsibility | Extracted method has a descriptive name; characterization tests pass |
| 2 | **Inline Temp** | A temporary variable is assigned once and used once | Variable adds no clarity beyond the expression it holds | Expression is readable without the variable; tests pass |
| 3 | **Replace Conditional with Polymorphism** | A switch/if-else chain dispatches on type | ≥3 branches dispatching on the same discriminator | Each branch becomes a method on a type; tests pass |
| 4 | **Decompose Conditional** | A complex boolean expression controls a branch | Expression has ≥3 clauses or requires comment to explain | Extracted into a named predicate function; tests pass |
| 5 | **Replace Magic Number with Named Constant** | A literal value appears in logic without explanation | The value has domain meaning beyond its numeric form | Constant name communicates intent; tests pass |
| 6 | **Remove Dead Code** | Code is unreachable or unused | Confirmed unreachable via static analysis or exhaustive search for callers | No test failures; no behavior change |
| 7 | **Simplify Nested Conditionals** | Nesting depth exceeds 3 levels | Guard clauses or early returns can flatten the structure | Nesting depth reduced; tests pass |
| 8 | **Extract Parameter Object** | A function takes >4 parameters | Parameters are logically related and travel together | Parameter count reduced; calling code updated; tests pass |

---

## Anti-Rationalization Table

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "I understand what this code does, so I don't need characterization tests." | Understanding what code does is not the same as proving your simplification preserves what it does. Characterization tests are not for your understanding — they are a regression tripwire. Your memory is fallible. The tests are not. Write them. |
| "This code is obviously dead — nothing calls it." | 'Obviously' is the most dangerous word in software. Code may be called via reflection, configuration, dynamic dispatch, or external systems you haven't examined. Prove it's dead through exhaustive caller search, not intuition. |
| "Writing characterization tests for code I'm about to simplify is wasted effort." | The tests are the proof that your simplification is correct. Without them, you are gambling that you haven't changed behavior. The 10 minutes writing tests saves the 4 hours debugging a subtle regression in production. |
| "The complexity budget is too strict — real-world code can't fit in these limits." | The limits are calibrated to human cognitive capacity. If a function exceeds cyclomatic complexity 10, it exceeds what a developer can hold in working memory. Complexity beyond the budget is a design problem, not a tooling problem. Redesign. |
| "I'll just update the tests to match the new behavior." | This is the single most dangerous action in the entropy reduction protocol. Updating tests to match new behavior destroys the safety net that proves behavior was preserved. If a characterization test fails, the code changed — revert and investigate. |
| "This refactoring is too small to document in the progress log." | If it's too small to document, it's too small to have done. Every simplification, no matter how minor, is recorded because the complexity delta is cumulative evidence of codebase health. Log it. |

---

## Evidence Requirement

A correctly executed entropy reduction produces the following verifiable artifacts:

1. **Characterization tests** written before simplification and passing against the original code.
2. **All existing tests passing** after simplification — zero regressions.
3. **A complexity delta report** in `progress_log.md` showing measurable improvement in at least one metric.
4. **No modified characterization tests** — if a characterization test was changed to pass, the protocol was violated.
5. **Intent documentation** — for any removed code, a written explanation of its original purpose and why removal is safe.

If any artifact is missing, the simplification is unverified and MUST NOT be committed.

---

## Failure Modes

| # | Failure Mode | Detection Signal | Recovery Action |
|---|---|---|---|
| 1 | **Behavior-altering simplification** — Refactoring changes observable behavior without detection | Characterization tests were not written, were insufficient, or were modified to pass. Production behavior diverges from pre-refactoring behavior. | Revert to pre-simplification state. Write comprehensive characterization tests. Re-attempt with single-step transformations, testing after each step. |
| 2 | **Premature abstraction** — Creating an abstraction layer for a single use case "in case we need it later" | New interface/base class/generic with exactly one implementation. Indirection added without current justification. | Remove the abstraction. Inline the single implementation. Apply the Rule of Three: abstract only when three concrete cases exist. |
| 3 | **Cleverness worship** — Replacing readable code with a compact but obscure one-liner | The simplified version requires more time to understand than the original. The 30-second rule is violated on the "simpler" code. | Revert. Readability is a complexity metric. A shorter version that's harder to understand has not reduced entropy — it has redistributed it from line count to cognitive load. |
| 4 | **Refactoring without coverage** — Simplifying code that has no existing tests and skipping characterization tests | No test files reference the target code. The characterization test step was skipped or produced zero tests. | Stop. Write characterization tests first. No coverage means no safety net. Refactoring untested code without adding tests is indistinguishable from introducing bugs. |
| 5 | **Metric gaming** — Splitting a complex function into many trivial functions to hit the complexity budget while increasing overall system complexity | Function count increases dramatically. Total cyclomatic complexity across all extracted functions exceeds the original. Call chains become deep. | Measure total complexity, not per-function complexity. Extraction is beneficial only when extracted functions are cohesive, reusable, and independently testable. Mindless splitting trades local simplicity for global confusion. |

---

## Integration Points

| Skill | Integration |
|---|---|
| **Pentagonal Audit** | The Readability and Architecture axes of the pentagonal audit surface candidates for entropy reduction. Findings of excessive complexity feed directly into this protocol. |
| **Test-First Verification** | Characterization tests written during Phase 2 follow test-first discipline. Existing test coverage determines whether characterization tests are needed or redundant. |
| **Progress Logging** | The complexity delta report is appended to `progress_log.md`, creating a historical record of complexity trends across the codebase. |
| **Pre-Commit Verification** | Complexity budget violations detected during pre-commit trigger the entropy reduction protocol. No commit proceeds if a function exceeds the budget without documented justification. |
| **Specification Adherence** | Behavior preservation is verified against the specification. If characterization tests reveal that current behavior deviates from the specification, that is a bug — not a simplification opportunity. |
| **Dependency Analysis** | Simplification may remove dependencies. The dependency analysis skill verifies that removed dependencies do not break downstream consumers. |
