# Requirement Distillation

**Objective:** Transform every ambiguous user request into a precise, testable specification document before any implementation begins.

---

## Operational Protocol

### Phase 1: Divergent Expansion

1. **You MUST read the user request at least twice.** On the first pass, extract the literal ask. On the second pass, extract the *implied* ask — what the user expects but did not say.

2. **You MUST generate a minimum of three distinct interpretations** of the request. For each interpretation, write one sentence explaining what the user could mean and one sentence explaining what would differ in the implementation.

3. **You MUST probe for implicit requirements** across every category in the following checklist:

| Category | Probe Question |
|---|---|
| Error Handling | What happens when inputs are invalid, missing, or malformed? |
| Platform Constraints | Which OS, runtime version, browser, or hardware must this support? |
| Performance | Are there latency, throughput, or memory constraints? |
| Backward Compatibility | Does this change break existing callers, APIs, or data formats? |
| Accessibility | Must the output meet accessibility standards (WCAG, screen readers, keyboard nav)? |
| Security | Does this handle user input, credentials, file paths, or network calls? |
| Concurrency | Can this be called in parallel? Must it be thread-safe? |
| Observability | Must this produce logs, metrics, or traces? |
| Data Volume | What is the expected input size? What is the worst-case input size? |
| Idempotency | Must this operation be safe to retry? |

4. **You MUST examine the existing codebase for context.** Search for:
   - Files, functions, or modules related to the request
   - Existing patterns, conventions, and naming schemes
   - Tests that reveal expected behavior
   - README, CONTRIBUTING, or architectural docs that constrain decisions

5. **You MUST identify at least three edge cases** the user has not mentioned. Document each with a concrete example input and the question: "What should happen here?"

### Phase 2: Convergent Narrowing

6. **You MUST select the single correct interpretation** by cross-referencing:
   - Evidence from the existing codebase (strongest signal)
   - Explicit statements in the user request
   - Convention and common sense for the domain
   - If ambiguity remains unresolvable, document it as an Open Question — do NOT guess silently.

7. **You MUST draft acceptance criteria that are programmatically verifiable.** Each criterion follows this template:

   ```
   GIVEN <precondition>
   WHEN <action>
   THEN <observable, measurable outcome>
   ```

   Criteria like "it works" or "it handles errors correctly" are **rejected**. Every criterion must reference a concrete input, output, state change, or side effect.

8. **You MUST define explicit scope boundaries.** Write two lists:
   - **IN SCOPE:** Specific deliverables, behaviors, and changes included in this work.
   - **OUT OF SCOPE:** Related work explicitly excluded. For each out-of-scope item, write one sentence explaining *why* it is excluded (prevents scope creep arguments later).

9. **You MUST create an assumption registry.** Every assumption follows this format:

   | ID | Assumption | Confidence | Verification Method |
   |---|---|---|---|
   | A-001 | The database schema will not change during implementation | HIGH | Check migration history before starting |
   | A-002 | Input files are always UTF-8 encoded | MEDIUM | Add encoding detection or fail explicitly |

   Confidence levels:
   - **HIGH** — Verified by code, docs, or explicit user statement
   - **MEDIUM** — Inferred from patterns but not confirmed
   - **LOW** — Pure guess; flag for immediate verification

10. **You MUST produce the specification document** in the output format defined below before proceeding to any implementation or planning skill.

---

## Specification Output Format

Every distilled requirement MUST produce a document with exactly these sections:

```markdown
# Specification: <Title>

## Context
<!-- Why does this work exist? What problem does it solve? Link to the originating request. -->

## Requirements
<!-- Numbered list. Each requirement is one atomic, testable behavior. -->
1. The system MUST ...
2. The system MUST ...
3. The system MUST NOT ...

## Acceptance Criteria
<!-- GIVEN/WHEN/THEN format. One criterion per requirement minimum. -->
- GIVEN ... WHEN ... THEN ...

## Scope Boundaries
### In Scope
- ...
### Out of Scope
- ... (Reason: ...)

## Assumptions
| ID | Assumption | Confidence | Verification Method |
|---|---|---|---|
| A-001 | ... | HIGH/MEDIUM/LOW | ... |

## Open Questions
<!-- Unresolved ambiguities. Each must have a proposed default and a flag for resolution. -->
- [ ] Q-001: ... (Default if unresolved: ...)
```

---

## Anti-Rationalization Table

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "The request is clear enough, I don't need to expand interpretations." | Clarity is an illusion. Users omit error handling, edge cases, and constraints in 100% of requests. Skipping divergent analysis guarantees you will discover missing requirements mid-implementation, causing rework. Run the protocol. |
| "I'll figure out the edge cases as I code — it's faster." | It is measurably slower. Discovering an edge case during implementation forces context-switching, partial rollbacks, and test rewrites. Discovering it during distillation costs one line in a document. Front-load the cost. |
| "Adding acceptance criteria is overhead — I'll just make sure it works." | "It works" is not a testable statement. Without GIVEN/WHEN/THEN criteria, you cannot write automated tests, you cannot verify completion, and you cannot detect regressions. The criteria ARE the definition of done. Write them. |
| "I don't want to gold-plate this with unnecessary requirements." | Distillation is the opposite of gold-plating. Gold-plating adds unrequested features. Distillation discovers requirements the user has but didn't state. Confusing the two leads to under-specified work that fails on delivery. |
| "Scope boundaries are obvious, I don't need to write them down." | If they are obvious, writing them takes thirty seconds. If they are not obvious (and they never are), the written boundary is the only defense against gradual scope expansion. Write them. |
| "I'll just start coding and ask questions if I get stuck." | Getting stuck means you have already wasted cycles on a wrong path. The distillation protocol surfaces blockers before a single line of code is written. Asking questions reactively is expensive; asking them proactively is cheap. |

---

## Evidence Requirement

Execution of this skill is proven by the existence of a **specification document** that satisfies ALL of the following:

- [ ] Contains all six required sections (Context, Requirements, Acceptance Criteria, Scope Boundaries, Assumptions, Open Questions)
- [ ] Every requirement uses RFC 2119 language (MUST, MUST NOT, SHALL, SHOULD)
- [ ] Every acceptance criterion follows GIVEN/WHEN/THEN format with concrete values
- [ ] At least three edge cases are addressed in requirements or acceptance criteria
- [ ] Scope boundaries include at least two OUT OF SCOPE items with reasons
- [ ] Assumption registry has at least one entry with confidence level and verification method
- [ ] No unresolved ambiguity exists without a documented default fallback

---

## Failure Modes

| # | Failure Mode | Detection | Recovery |
|---|---|---|---|
| 1 | **Premature solutioning** — specification contains implementation details (specific libraries, algorithms, data structures) instead of behavioral requirements. | Review the Requirements section: if any item describes *how* instead of *what*, it has failed. | Strip implementation details. Rewrite each requirement as a behavior: "The system MUST <verb> <observable outcome>." |
| 2 | **Scope amnesia** — scope boundaries were written but later ignored; implementation includes out-of-scope work. | Diff the delivered work against the In Scope list. Any file or behavior not traceable to an in-scope item is a violation. | Revert out-of-scope changes. If the scope was wrong, amend the spec first, then implement. Never implement-then-justify. |
| 3 | **Assumption burial** — assumptions were made silently during coding without appearing in the registry. | Search the implementation for hardcoded values, magic numbers, default paths, or platform-specific calls that have no matching assumption entry. | Extract each silent assumption into the registry. Assign a confidence level. Verify LOW-confidence assumptions immediately. |
| 4 | **Vague acceptance criteria** — criteria use subjective language ("fast," "correct," "handles errors") that cannot drive a test. | Run each criterion through the test: "Can I write an automated assertion for this exact sentence?" If no, it is vague. | Rewrite with concrete values: "responds in under 200ms for inputs up to 10,000 records" instead of "responds quickly." |
| 5 | **Single-interpretation tunnel vision** — only one interpretation was considered, and it was wrong. | The divergent phase produced fewer than three interpretations, or all interpretations are trivially similar. | Force yourself to generate a contradictory interpretation. Ask: "What if the user meant the exact opposite of my first reading?" |

---

## Integration Points

| Skill | Relationship |
|---|---|
| `02_strategic_decomposition` | The specification document produced here is the **sole input** to strategic decomposition. Decomposition without a spec is prohibited. |
| `test_first_development` | Acceptance criteria from this skill feed directly into test case generation. Every GIVEN/WHEN/THEN becomes a test. |
| `codebase_archaeology` | Existing code analysis performed during divergent expansion reuses the archaeology skill's search patterns and conventions inventory. |
| `scope_management` | Scope boundaries defined here are the authoritative reference for any scope dispute during implementation. Changes require spec amendment. |
| `mission_validation` | The completed specification is validated against the original user request to confirm alignment before proceeding. |
