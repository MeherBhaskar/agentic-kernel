# 12 · Semantic Navigation

> Navigating large codebases efficiently using structural understanding, progressive refinement, and the navigation hierarchy — from broad orientation to precise symbol location.

**Objective:** You MUST navigate codebases by progressively narrowing from architecture-level understanding to exact symbol location, never by brute-force searching, so that you reach the correct code in minimum steps with maximum contextual awareness.

---

## Operational Protocol

### Phase 1 — The Navigation Hierarchy

You MUST follow this hierarchy top-to-bottom. Never skip levels unless you have confirmed evidence that a higher level provides no useful information.

| Level | Tool / Method | Purpose | When to Use |
|-------|--------------|---------|-------------|
| **1. Architecture Docs** | Read `.docs/architecture/`, `ARCHITECTURE.md`, design docs | Understand system boundaries, module responsibilities, data flow | Always first in an unfamiliar codebase |
| **2. Directory Structure** | `tree -L 2 -d`, `ls -la` | Understand project layout, identify module boundaries | Before opening any source file |
| **3. File-Level Search** | `grep -rl`, `find -name`, `find -path` | Locate candidate files by name or content | When you know *what concept* but not *which file* |
| **4. Symbol-Level Search** | Go-to-definition, find-references, find-implementations | Locate exact functions, classes, types | When you know *which symbol* to find |
| **5. Full-Text Search** | `grep` / ripgrep with filters | Find exact string matches | Last resort — only when symbol search fails |

1. **Start at Level 1.** Read existing architecture docs. If none exist, note this gap and proceed to Level 2.
2. **Descend one level at a time.** After each level, you MUST state what you learned and what question remains unanswered before descending.
3. **Never start at Level 5.** Full-text search without structural context produces noise. You MUST have at least Level 2 understanding before any text search.

### Phase 2 — Codebase Orientation Protocol

When entering a codebase for the first time (or re-entering after significant time), execute this sequence in order:

| Step | Action | Command / Method | Output |
|------|--------|-----------------|--------|
| 1 | Read the README | `head -n 100 README.md` | Project purpose, setup instructions, key concepts |
| 2 | List top-level directories | `tree -L 1` or `ls -la` | Module layout, separation of concerns |
| 3 | Find entry points | `find . -maxdepth 2 -name 'main.*' -o -name 'index.*' -o -name 'app.*' -o -name 'server.*'` | Where execution begins |
| 4 | Trace one execution path | Read entry point → follow imports → reach leaf function | End-to-end understanding of one flow |
| 5 | Locate test directories | `find . -type d -name '*test*' -o -name '__tests__' -o -name 'spec'` | Test conventions and coverage structure |
| 6 | Check for architecture docs | `find . -path '*doc*' -name '*.md' \| head -n 20` | Existing documentation state |

4. **Complete ALL six steps before writing any code.** Partial orientation leads to incorrect assumptions about project structure.
5. **Record the orientation summary.** After completing the protocol, write a 5–10 line summary: project purpose, key directories, entry points, test location, notable patterns.

### Phase 3 — Directory-First Orientation

6. **Before diving into any file, understand its directory.** List the directory contents, read any local README or index file, and identify sibling files that share the same concern.
7. **Map module boundaries.** Identify which directories represent distinct modules, packages, or services. Understand the dependency direction between them.
8. **Identify configuration files.** Locate `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, or equivalent. These reveal dependencies, build targets, and project structure.

### Phase 4 — Symbol-Based Navigation

9. **Prefer language-aware navigation over text search.** Go-to-definition, find-all-references, and find-implementations understand scope, imports, and type hierarchies. Text grep does not.
10. **Trace the import chain.** To understand a function, trace both directions:
    - **Upstream (callers):** Who calls this function? What context does the caller provide?
    - **Downstream (callees):** What does this function call? What side effects does it produce?
11. **Apply the 3-File Rule.** Before modifying ANY file, you MUST read these three related files:

| File | Why |
|------|-----|
| **Primary caller** | Understand how the code you're changing is invoked — what arguments, what expectations |
| **Primary callee** | Understand what the code you're changing depends on — what contracts it relies on |
| **Test file** | Understand what behavior is currently tested — what you must preserve and what test to update |

12. **If any of the three files does not exist** (e.g., no test file), acknowledge the gap explicitly. Do not silently skip the rule.

### Phase 5 — The Ripgrep Discipline

13. **Always use file-type filters.** Never run an unfiltered search across the entire repo.
    ```bash
    # Correct — scoped and filtered
    grep -rn --include='*.py' 'def process_request' src/

    # Also correct — using ripgrep with type filter
    rg --type py 'def process_request' src/

    # WRONG — unscoped, will match vendored code, docs, binaries
    grep -rn 'process_request' .
    ```
14. **Exclude noise directories.** Always exclude: `node_modules/`, `vendor/`, `.git/`, `build/`, `dist/`, `__pycache__/`, `.venv/`, `target/`.
    ```bash
    rg --type py --glob '!**/{node_modules,vendor,build,dist,__pycache__,.venv,target}/**' 'pattern' .
    ```
15. **Limit result count.** Add `| head -n 30` or use `-m 30` to prevent result flooding. If you get >30 matches, your query is too broad — refine it.

### Phase 6 — Search Strategy Escalation

16. **Follow this escalation order.** Do not jump to expensive strategies prematurely.

| Order | Strategy | Example | When to Escalate |
|-------|----------|---------|-----------------|
| 1 | Exact string | `rg 'processPayment'` | No matches found |
| 2 | Regex pattern | `rg 'process[_-]?[Pp]ayment'` | Naming convention unclear |
| 3 | Symbol/semantic search | Go-to-definition, find-references | String not greppable (too common, dynamically generated) |
| 4 | Manual traversal | Read directory structure, follow imports by hand | All automated searches fail |

17. **At each escalation, record what you tried and why it failed.** This prevents repeating the same failed search.

### Phase 7 — The Lost Detector

18. **If you have spent more than 3 navigation actions without finding what you need, STOP.** Execute this recovery protocol:
    1. Restate what you are looking for in one sentence
    2. List the searches you have already tried
    3. Identify what assumption might be wrong (wrong filename? wrong directory? wrong terminology?)
    4. Choose a fundamentally different search angle
    5. If still lost after the second attempt, return to Level 1 (architecture docs / directory structure) and re-orient

19. **Never continue navigating on momentum.** If you cannot articulate what you expect to find in the next file you open, you are navigating blindly. Stop and restate your goal.

---

## Anti-Rationalization Table

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "I'll just grep for it — faster than reading docs." | Grep without context produces dozens of false positives. The 2 minutes you spend reading architecture docs saves the 15 minutes you spend chasing irrelevant matches. Docs tell you *where to look*; grep only tells you *where a string appears*. |
| "I already know this codebase — I can skip orientation." | Codebases change. Other contributors merge code daily. Your cached mental model decays with every commit you haven't seen. Run at least a truncated orientation (steps 1–3) on re-entry. |
| "There are no architecture docs, so I'll skip Level 1." | The *absence* of docs is itself critical information. Note the gap, then compensate by spending extra time on Level 2 (directory structure) to build the architectural understanding that docs would have provided. |
| "I only need to change one line — the 3-file rule is overkill." | One-line changes cause cascading failures when the caller passes different arguments than you assumed, or the test asserts behavior you just broke. The 3-file rule exists precisely for changes that *seem* trivial. |
| "Ripgrep is fast enough — filters just slow me down." | Speed of execution is irrelevant if you drown in 500 results from `node_modules`. Filters don't slow ripgrep down — they speed *you* up by eliminating noise before it reaches your context. |
| "I'll read the whole file to get full context." | Full-file reads violate bounded observation limits and waste context on irrelevant code. Read the function, its imports, and its immediate neighbors. If you need broader context, make a second targeted read. |

---

## Evidence Requirement

Correct execution of this skill produces these verifiable artifacts:

| Artifact | Verification Method |
|---|---|
| **Orientation summary** | A 5–10 line summary exists documenting: project purpose, key directories, entry points, test location, and notable patterns — written before any code changes |
| **Navigation log** | Each file opened has a stated reason. No file was opened "to see what's in there" without a guiding question |
| **3-file evidence** | Before every modification, the agent's log shows reads of the caller, callee, and test file (or an explicit acknowledgment that one is missing) |
| **Search refinement trail** | Searches show progressive narrowing: type-filtered, directory-scoped, with result counts decreasing across attempts |
| **No unfiltered searches** | Every `grep` / `rg` command in the log includes file-type or directory filters |
| **Lost-detector activation** | If navigation stalled, the recovery protocol (restate → list tried → reassess → pivot) is present in the log |

---

## Failure Modes

### 1. Brute-Force Grep Syndrome
- **Symptom:** Agent searches for common words (`data`, `handler`, `process`) across the entire repo, receives 200+ results, then picks one at random or gives up.
- **Detection:** Any search producing >50 unfiltered results. Any search term with <5 characters and no file-type filter.
- **Recovery:** Cancel the search. Add file-type filter (`--type`), directory scope (`src/`), and word-boundary anchors (`\b`). If the term is too generic, switch to symbol-level search (Level 4).

### 2. Tunnel Vision
- **Symptom:** Agent edits a function without reading its callers. The change breaks every call site because the function signature or return type changed.
- **Detection:** A file modification with no preceding read of any file that imports or calls the modified symbol.
- **Recovery:** Run find-all-references on the modified symbol. Read every caller. Fix broken call sites. Enforce the 3-file rule retroactively.

### 3. Reference Blindness
- **Symptom:** Agent renames or removes a function. Downstream code still references the old name, causing runtime errors or build failures.
- **Detection:** Build errors or test failures referencing undefined symbols after a rename or deletion.
- **Recovery:** Run find-all-references on the old symbol name. Update every reference. Run the full test suite to confirm no remaining references.

### 4. Lost-in-Codebase Syndrome
- **Symptom:** Agent opens 10+ files in sequence without making progress toward the goal. Navigation becomes circular — revisiting previously opened files.
- **Detection:** More than 5 consecutive file reads without a code edit or a clear stated finding. Reopening a file that was read within the last 10 actions.
- **Recovery:** Activate the lost detector (Phase 7, step 18). Restate the objective. Return to Level 2 (directory structure) and re-orient. If the objective itself is unclear, stop navigation and clarify requirements.

### 5. Premature File Opening
- **Symptom:** Agent opens source files before understanding the project layout. Reads code out of context, makes incorrect assumptions about module relationships.
- **Detection:** Source file reads occurring before any `tree`, `ls`, or README read in the session log.
- **Recovery:** Close all open files. Execute the Codebase Orientation Protocol (Phase 2) from step 1. Resume navigation only after completing orientation.

---

## Integration Points

| Connected Skill | Relationship |
|---|---|
| **Bounded Observation** (11) | Every navigation action produces an observation. All observations MUST obey bounded observation limits. Navigation decides *what* to observe; bounded observation governs *how much* to observe. |
| **Architecture-First** (01) | Architecture docs are Level 1 of the navigation hierarchy. If no architecture docs exist, this skill's orientation protocol produces the initial architectural understanding that should then be documented per the architecture-first skill. |
| **Incremental Development** (03) | Navigation informs scope. The 3-file rule ensures you understand the blast radius before making incremental changes. Navigation precedes every development cycle. |
| **Test-Driven Validation** (02) | The 3-file rule mandates reading the test file. Navigation's import-chain tracing reveals which tests cover the code being modified. |
| **Failure Recovery** | When debugging, navigation is the primary tool for tracing error origins. The search strategy escalation and lost-detector protocols prevent wasted time during high-pressure recovery situations. |

---

## Quick Reference Checklist

Before navigating a codebase, confirm:

- [ ] I completed orientation (or confirmed I have recent orientation for this codebase)
- [ ] I stated what I am looking for in one sentence
- [ ] I am starting at the highest applicable level of the navigation hierarchy
- [ ] My search commands include file-type filters and directory scopes
- [ ] I have excluded noise directories (node_modules, vendor, build, etc.)
- [ ] Before modifying any file, I read the caller, callee, and test file
- [ ] My search results are under 30 matches — if not, I refined the query
- [ ] I am not navigating on momentum — I can articulate what I expect to find next
- [ ] If stuck for >3 actions, I activated the lost-detector recovery protocol
