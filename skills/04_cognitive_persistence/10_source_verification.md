# Source Verification

> Ground every claim about the codebase in actual source code and observable behavior — never in assumptions, training data, or prior knowledge.

---

## Operational Protocol

### Phase 1: Establish the Source-of-Truth Hierarchy

1. You MUST internalize and follow this authority ranking for resolving conflicting information. Higher rank overrides lower rank, always:

| Rank | Source | Authority Level | When to Use |
|---|---|---|---|
| 1 | Running code behavior (actual execution output) | **ABSOLUTE** | Final arbiter of all disputes. If the code does X, then X is the truth regardless of what any document says. |
| 2 | Passing tests | **HIGH** | Tests encode expected behavior. A passing test is evidence of what the code actually does. |
| 3 | Inline code comments | **MEDIUM-HIGH** | Comments near the code are most likely to be maintained, but can still drift. Verify against Rank 1 if uncertain. |
| 4 | README and documentation files | **MEDIUM** | Often written once and updated rarely. Trust structure and intent, but verify specific claims. |
| 5 | Commit messages | **MEDIUM-LOW** | Describe what the author *intended* to do, not necessarily what was achieved. Useful for context, unreliable for specifics. |
| 6 | Agent's prior knowledge / training data | **UNVERIFIED** | Treat as hypothesis only. Never act on this without verification against Rank 1–5 sources. |

2. When two sources conflict, the higher-ranked source wins. Document the conflict and resolution.

### Phase 2: Read-Before-Claim Protocol

3. Before making ANY assertion about how a function, class, module, or system behaves, you MUST read the actual source code first.
4. "Read" means opening the file and examining the relevant lines. Not recalling, not assuming, not inferring from the function name — reading.
5. After reading, anchor your claim with a specific reference:
   - ✅ `function validate_input() at src/validators.py:45 raises ValueError for empty strings`
   - ❌ `the validate function probably checks for empty strings`
6. If you cannot provide a file path and line number for a claim, the claim is unverified. Mark it explicitly: `[UNVERIFIED: <claim>]`.

### Phase 3: API Contract Verification

7. Before calling ANY function (internal or from a dependency), verify the following against the actual source or installed package:

| Contract Element | Verification Method |
|---|---|
| Function exists | `grep -rn "def function_name\|function function_name"` or read the source file |
| Parameter names and types | Read the function signature in source |
| Required vs. optional parameters | Read the signature; check for default values |
| Return type and structure | Read the return statements in the function body |
| Side effects | Read the function body for writes, mutations, external calls |
| Error conditions | Read for `raise`, `throw`, error returns, and guard clauses |
| Deprecation status | Check for deprecation decorators or comments |

8. For external dependencies, verify against the **actually installed version**, not the latest documentation:
   - Check `requirements.txt`, `pyproject.toml`, `package.json`, or equivalent for the pinned version.
   - If the version is unpinned, check the installed version via the package manager (e.g., `pip show <package>`, `npm ls <package>`).
   - Cross-reference the installed version's API, not the latest release's API.

9. You MUST NOT assume backward compatibility between library versions. A function that exists in v2.0 may not exist in v1.8.

### Phase 4: The Verification Chain

10. Every factual claim about the codebase that influences a decision MUST be part of a **verification chain**:

```
Claim: "<factual assertion>"
Source: <file_path>:<line_number>
Verified: <timestamp>
Method: <how you verified — read source / ran tests / executed code>
```

11. If a claim cannot be placed in a verification chain, it is a hypothesis. Hypotheses are permitted but MUST be:
    - Explicitly labeled as `[HYPOTHESIS]`
    - Tested before being acted upon
    - Promoted to verified claims only after evidence is obtained

12. You MUST NOT build on unverified hypotheses. If Step N depends on a hypothesis from Step N-1, verify the hypothesis before proceeding to Step N.

### Phase 5: The Hallucination Check

13. Before writing any line of code, apply this checklist:

| Check | Question | If "No" |
|---|---|---|
| Function exists | Have I verified this function exists in the actual source/library? | STOP. Find the real function or write it. |
| Correct signature | Have I verified the parameter names, types, and order? | STOP. Read the actual signature. |
| Correct import path | Have I verified the module path matches the actual file structure? | STOP. Check the actual directory layout. |
| Correct return type | Have I verified what this function actually returns? | STOP. Read the return statements. |
| Version compatible | Am I using syntax/features available in the installed version? | STOP. Check the installed version's API. |

14. If you answer "No" to ANY check, you MUST stop and verify before writing the code. Do NOT write the code with a plan to "fix it later."

### Phase 6: Continuous Verification During Execution

15. After writing code, run it. If the behavior differs from your expectation:
    - The code's behavior is the truth (Rank 1 source).
    - Your expectation was wrong. Trace back to find which assumption was incorrect.
    - Update your mental model and any documentation to reflect reality.
16. Do NOT rationalize unexpected behavior. If a function returns `None` when you expected a `dict`, the function returns `None`. Investigate why, don't explain it away.

---

## Anti-Rationalization Table

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "I'm confident this function exists; I've seen it used in similar projects." | Similar projects are not this project. Confidence without verification is the definition of hallucination. Read the actual source file. 30 seconds of reading prevents 30 minutes of debugging phantom APIs. |
| "The function name is self-explanatory; I don't need to read the implementation." | `deleteUser()` might soft-delete, hard-delete, archive, or throw NotImplementedError. Names describe intent, not behavior. Read the implementation. |
| "I'll verify later after the code is written." | Unverified code compounds. Every line built on an unverified assumption becomes a line that must be rewritten when the assumption fails. Verify first, write once. |
| "The documentation says this is how it works." | Documentation is Rank 4. Code behavior is Rank 1. If they disagree, the code wins. Read the code. |
| "This is a standard library function; it works the same everywhere." | Standard library APIs change between language versions, have platform-specific behavior, and have edge cases the docs don't cover. Verify the installed version. |
| "Checking every function call would make me too slow." | Checking takes seconds. Debugging a hallucinated API takes minutes to hours. Verification is not overhead — it is the fastest path to correct code. |

---

## Evidence Requirement

Execution of this skill is verified by these observable behaviors and artifacts:

| Evidence | Verification Check |
|---|---|
| Source references in claims | Every factual assertion about code behavior cites a specific `file:line` reference. No claims are made without source backing. |
| API verification traces | Before each function call in new code, the agent read the function's actual source or documentation for the installed version. Visible in the agent's exploration history. |
| `[UNVERIFIED]` / `[HYPOTHESIS]` markers | Any claim the agent cannot back with source is explicitly marked, not stated as fact. |
| Version-aware dependency usage | `requirements.txt` / `package.json` versions were checked before using dependency APIs. No features from newer versions than installed are used. |
| Hallucination check evidence | New code only calls functions that demonstrably exist in the codebase or installed dependencies. Zero phantom imports or calls. |

---

## Failure Modes

### 1. Hallucinated APIs
- **Symptom:** Code calls functions, methods, or classes that do not exist in the codebase or installed dependencies. Results in `ImportError`, `AttributeError`, `NameError` at runtime.
- **Detection:** Run the code. Grep for the function name in the codebase and installed packages. If it doesn't exist, it was hallucinated.
- **Recovery:** Delete the hallucinated call. Read the actual source to find the real function. If no equivalent exists, implement it. Add the real function to the verification chain.

### 2. Version Confusion
- **Symptom:** Code uses syntax, parameters, or features from a different version of a library than what is installed. May produce subtle bugs rather than hard errors.
- **Detection:** Check installed version (`pip show`, `npm ls`). Compare the used API against that specific version's changelog or documentation.
- **Recovery:** Pin to the installed version's API. If the newer API is needed, explicitly upgrade the dependency and update the lock file. Do not silently assume the latest version.

### 3. Documentation Drift
- **Symptom:** Agent trusts README or doc comments that describe behavior the code no longer exhibits. Results in incorrect assumptions about function contracts.
- **Detection:** Compare documentation claims against actual execution output. If they differ, the documentation has drifted.
- **Recovery:** Trust the code (Rank 1). Update the documentation to match actual behavior. Add a note in the commit message that docs were corrected.

### 4. Cargo-Cult Patterns
- **Symptom:** Agent copies a code pattern from one part of the codebase (or from training data) without verifying it applies in the new context. Pattern may use deprecated APIs, different configurations, or inapplicable assumptions.
- **Detection:** The copied pattern works in its original location but fails or behaves unexpectedly in the new location. Dependencies or configurations differ between contexts.
- **Recovery:** Read the pattern's implementation fully. Identify every assumption it makes. Verify each assumption holds in the new context. Adapt the pattern — do not paste it.

### 5. Confabulation
- **Symptom:** Agent constructs a plausible-sounding but fabricated explanation for why code behaves a certain way, rather than tracing the actual execution path.
- **Detection:** The explanation sounds reasonable but cannot be verified by reading the source. No specific file:line references are provided. Actual execution contradicts the explanation.
- **Recovery:** Stop explaining. Start reading. Trace the actual execution path step by step. Replace the fabricated explanation with observed behavior. If the behavior is genuinely unclear, mark it as `[REQUIRES INVESTIGATION]` rather than inventing an explanation.

---

## Integration Points

| Skill | Relationship |
|---|---|
| **Structural Cartography** | The architecture index and entry point catalog are outputs of Structural Cartography. Source Verification validates that these artifacts accurately reflect the actual codebase. Every Module Card claim must pass source verification. |
| **Context Lifecycle Management** | Facts recorded in context snapshots must satisfy Source Verification standards. The `Facts Established` table requires `file:line` sources. Confidence decay triggers re-verification through this skill's protocols. |
| **Assumption Logging** | Unverified claims identified by Source Verification become entries in the assumption log. When a `[HYPOTHESIS]` is verified or falsified, the assumption log is updated accordingly. |
| **Decision Journaling** | Decisions must be grounded in verified facts, not assumptions. Source Verification provides the evidentiary standard that decision rationale must meet. |
| **Error Triage** | Root cause analysis during error triage must follow Source Verification protocols — trace actual execution paths, read actual error messages, verify actual function behavior. No speculative diagnoses. |
