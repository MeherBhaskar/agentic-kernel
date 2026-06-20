# 05 · Incremental Proof Cycles

> **Objective:** Synthesize correct code through test-driven thin vertical slices — write a failing test first, implement the minimum code to pass it, then refactor while green — ensuring every line of production code exists because a test demanded it.

---

## 1 · Why TDD Is Non-Negotiable for Agents

| Human Developer | Autonomous Agent |
|---|---|
| Can run the code mentally, use debuggers, inspect state interactively | Cannot interactively debug; must rely on test output as the sole feedback signal |
| Has domain intuition that catches "this looks wrong" | Produces plausible-looking code that compiles but silently does the wrong thing |
| Can tolerate some manual verification | Has NO verification mechanism other than automated tests |
| Writes tests for confidence | MUST write tests for correctness — tests are the ONLY proof that code works |

**Without tests, an agent is guessing.** Plausible code is not correct code. The only empirical evidence of correctness is a passing test that was written BEFORE the implementation.

---

## 2 · Operational Protocol

### Phase A: Define the Verification Oracle

1. **Read the task specification.** Identify the exact expected behavior: inputs, outputs, side effects, error cases.
2. **Define expected results BEFORE writing any test code.** Write down, in plain language:
   - "Given [input/state], the system should [behavior], producing [output]."
   - List at least: one happy path, one edge case, one error case.
3. **Do NOT derive expected results from the implementation.** The oracle comes from the specification, not from running the code and seeing what it produces.

### Phase B: The Fail-Pass-Optimize Cycle

4. **RED — Write ONE failing test.**
   - The test MUST be specific: one behavior, one assertion (or a tightly related group of assertions).
   - Use the naming convention: `test_<unit>_<scenario>_<expected_result>`
     - Example: `test_login_with_expired_token_returns_401`
     - Example: `test_parse_csv_with_empty_rows_skips_blanks`
     - Example: `test_calculate_tax_with_negative_income_raises_value_error`
   - Run the test. **Confirm it FAILS.** If it passes without implementation, either the test is tautological or the behavior already exists. Investigate.
   - **The failure message MUST be meaningful.** If the test fails with a generic error, improve the assertion message.

5. **GREEN — Write the MINIMUM code to make the test pass.**
   - Minimum means minimum. Do NOT implement features the test doesn't demand.
   - Do NOT write "clean" or "elegant" code yet. Write the simplest thing that passes.
   - Run the test. **Confirm it PASSES.**
   - Run ALL existing tests. **Confirm nothing else broke.**

6. **REFACTOR — Improve the code while ALL tests stay green.**
   - Eliminate duplication, improve naming, extract functions, simplify logic.
   - After EVERY refactor edit, run ALL tests. If any test fails, undo the refactor immediately.
   - Refactoring MUST NOT change behavior. If you need new behavior, go back to RED.

7. **Repeat** from step 4 for the next behavior slice.

### Phase C: Slice Completion

8. **After all slices for a task are complete**, run the full verification suite (all tests, linter, type-checker).
9. **Proceed to the State Checkpoint Protocol** for the binary commit gate.

---

## 3 · Thin Vertical Slices

Each slice delivers a working, testable increment through ALL necessary layers (data, logic, interface).

### Correct Slicing

```
TASK: "User can register with email and password"

Slice 1: Validate email format
  Test: test_validate_email_with_valid_format_returns_true
  Test: test_validate_email_with_missing_at_sign_returns_false
  Impl: Email validation function

Slice 2: Hash and store password
  Test: test_hash_password_produces_different_hash_each_call
  Test: test_verify_password_with_correct_input_returns_true
  Impl: Password hashing utilities

Slice 3: Create user record
  Test: test_create_user_with_valid_data_persists_record
  Test: test_create_user_with_duplicate_email_raises_conflict
  Impl: User creation logic + storage

Slice 4: Registration endpoint
  Test: test_register_endpoint_with_valid_data_returns_201
  Test: test_register_endpoint_with_invalid_email_returns_422
  Impl: HTTP handler wiring slices 1-3 together
```

### Incorrect Slicing (Anti-Patterns)

| Anti-Pattern | Why It Fails |
|---|---|
| **Horizontal slices** — "First build all the database layer, then all the business logic, then all the API" | No slice is independently testable or demonstrable. Integration errors hide until the very end. |
| **Big-bang slices** — "Implement the entire registration feature in one slice" | Too large to test incrementally. Failures are hard to localize. Violates the ≤50-line-per-edit rule. |
| **Test-last slices** — "Implement first, test after" | You will unconsciously shape tests to match implementation bugs. The verification oracle is corrupted. |

---

## 4 · Testing Pyramid

```
        ╱╲
       ╱ E2E ╲          <10% of tests
      ╱────────╲         Slow, fragile, high coverage per test
     ╱Integration╲      ~20% of tests
    ╱──────────────╲     Medium speed, test component interactions
   ╱   Unit Tests   ╲   >70% of tests
  ╱──────────────────╲   Fast, isolated, test single behaviors
```

| Level | Scope | Speed | Isolation | When to Write |
|-------|-------|-------|-----------|---------------|
| **Unit** | Single function/method/class | <100ms per test | Full (no I/O, no network, no DB) | EVERY slice |
| **Integration** | Component interactions, API contracts | <5s per test | Partial (may use test DB, mock services) | When wiring components together |
| **E2E** | Full user workflow | <30s per test | None (real system) | After feature completion, sparingly |

**Rules:**
- You MUST write unit tests for every slice. This is not optional.
- You MUST write integration tests when connecting components.
- You SHOULD write E2E tests only for critical user paths.
- If a test requires network access, external services, or slow I/O, it is NOT a unit test. Reclassify it.

---

## 5 · Test Isolation Requirements

Every test MUST satisfy ALL of the following:

| Requirement | Verification |
|---|---|
| **Independent** | The test passes when run alone AND when run with all other tests |
| **Deterministic** | The test produces the same result on every run (no randomness, no time-dependence, no race conditions) |
| **No shared mutable state** | The test does not read or write global variables, shared files, or shared database rows that other tests also access |
| **Self-contained setup** | The test creates its own fixtures/data and tears them down after completion |
| **Order-independent** | The full test suite passes regardless of execution order |

**Verification method:** Periodically run tests in randomized order. If any test fails, it has a hidden dependency. Find and eliminate it.

---

## 6 · The Characterization Test Protocol

When MODIFYING existing code (not writing new code):

1. **BEFORE making any changes**, write characterization tests that capture the current behavior.
2. These tests document what the code ACTUALLY does, not what it SHOULD do.
3. Run the characterization tests. They MUST pass against the current code.
4. NOW modify the code. Characterization tests that should still pass MUST still pass. Tests for changed behavior should fail — update them to reflect the new expected behavior.
5. This ensures you know exactly what changed and can verify that unrelated behavior was preserved.

**Rule:** Never modify code that has no tests. Write characterization tests FIRST, then modify.

---

## 7 · Anti-Rationalization Table

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "The implementation is simple enough that tests aren't necessary." | Simple implementations have simple tests. If it's so simple, the test takes 30 seconds to write. The cost of NOT testing is discovering a subtle bug six tasks later when the debugging cost is 100x higher. |
| "I'll write the tests after I finish the implementation — it's faster." | Test-after is verification theater. You will unconsciously write tests that match your bugs, not the spec. The test MUST be written to the specification, which requires writing it BEFORE you know how the code works. |
| "Writing a test for this would require too much mocking/setup." | Excessive mocking requirements indicate a design problem. The code is too coupled. Refactor the design so the unit under test has clean, narrow dependencies. The difficulty of testing IS the design feedback. |
| "I already ran it manually and it works." | 'I ran it manually' is not a repeatable verification. Manual checks cannot be re-run by the CI, by future tasks, or by other agents. Automated tests are the ONLY durable proof of correctness. |
| "This is just a refactor — behavior doesn't change, so I don't need tests." | Refactoring WITHOUT tests is just editing code and hoping. Tests are the safety net that PROVES behavior didn't change. Write characterization tests first, then refactor while they stay green. |
| "The existing tests are bad/flaky, so I'll skip testing for now." | Bad tests are a problem to fix, not an excuse to skip testing. Write GOOD tests for your new code. Fix or delete the flaky tests. Two wrongs don't make a right. |

---

## 8 · Evidence Requirement

Execution of this skill is proven by:

- [ ] **Failing test output** captured BEFORE implementation (proving Red phase was real)
- [ ] **Passing test output** captured AFTER implementation (proving Green phase succeeded)
- [ ] **All tests still passing** after refactoring (proving Refactor phase preserved behavior)
- [ ] **Test names** following the `test_<unit>_<scenario>_<expected_result>` convention
- [ ] **Test-to-implementation ratio** of at least 1:1 (lines of test ≥ lines of implementation)
- [ ] **No test that was written after the implementation** it verifies (commit timestamps or iteration logs demonstrate test-first ordering)

---

## 9 · Failure Modes

| Failure Mode | Detection Signal | Recovery Action |
|---|---|---|
| **Test-after rationalization** | Tests are committed in the same diff as implementation, but iteration log shows implementation was written first | Re-examine the tests. Do they test SPECIFICATION behavior or IMPLEMENTATION behavior? If they mirror implementation quirks, delete them and rewrite from spec. |
| **Tautological tests** | Tests mock a dependency and then assert the mock returns what it was configured to return. No real logic is tested. | Identify what behavior the test SHOULD verify. Rewrite to test actual logic with real (or realistic) inputs and outputs. |
| **Test pollution** | Tests pass individually but fail when run together (or in different order) | Find the shared state: global variables, class-level mutables, database rows, temp files. Isolate each test with proper setup/teardown. |
| **Coverage theater** | Coverage report shows >90% but critical paths have no meaningful assertions | Review each test's assertions. A test that executes code without asserting correct behavior is not a test — it's a smoke screen. Add meaningful assertions. |
| **Slice too large** | A single Fail-Pass-Optimize cycle involves >50 lines of implementation or >3 test cases | Break the slice into smaller slices. Each cycle should be one behavior, one test, minimal implementation. |

---

## 10 · Integration Points

| Skill | Relationship |
|---|---|
| **Convergent Iteration** | The Observe phase of the RAO loop runs the tests created by this skill. Test results are the convergence signal. Without proof cycles, convergent iteration has no feedback. |
| **State Checkpoint Protocol** | Tests are part of the atomic commit. A commit without tests is an unverified commit and violates the checkpoint protocol. |
| **Task Decomposition** | Each decomposed task should map to one or more thin vertical slices. If a task cannot be sliced, it needs further decomposition. |
| **Structured Reasoning** | The verification oracle (expected results) is defined during reasoning. If you cannot state expected behavior before testing, you have not reasoned enough. |
| **Context Management** | Test names serve as living documentation of system behavior. Well-named tests reduce the need to re-read implementation code for context. |
