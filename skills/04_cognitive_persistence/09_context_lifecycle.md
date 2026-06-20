# Context Lifecycle Management

> Manage agent memory across sessions with explicit supersession, confidence decay, and structured handoff to prevent knowledge rot and context amnesia.

---

## Operational Protocol

### Phase 1: Session Resumption

1. On every session start, locate the most recent snapshot file matching `.docs/context/SNAPSHOT_*.md`.
2. Read the snapshot in full. Do NOT skip any section.
3. Verify the snapshot against current reality:
   - Run `git status` and `git log -1` — confirm the working branch and last commit match the snapshot's recorded state.
   - If they do not match, treat the ENTIRE snapshot as LOW confidence. Note the discrepancy explicitly before proceeding.
4. Identify all facts in the snapshot with LOW confidence (verified >24 hours ago). Re-verify each one against the actual codebase before acting on it.
5. Resume work from the snapshot's `Next Steps` section. Do NOT restart from scratch unless the snapshot is irrecoverably stale.

### Phase 2: Active Session Management

6. Maintain a running mental model of the session's key state. Track:
   - Current task identifier
   - Working branch
   - Last known-good commit (tests passing)
   - Decisions made and their rationale
   - Open questions awaiting resolution
7. When new information contradicts a previously recorded fact, execute the **Supersession Protocol**:
   - Locate the original fact in the relevant documentation or snapshot.
   - Append `[SUPERSEDED by <reference>]` to the original entry. Do NOT delete it silently.
   - Record the new fact with its source and timestamp.
   - If the superseded fact appeared in a snapshot, note the correction in the next snapshot's `Warnings` section.
8. Apply **Confidence Decay** to all factual claims:

| Time Since Verification | Confidence Level | Required Action |
|---|---|---|
| < 1 hour | HIGH | Act on it freely |
| 1–24 hours | MEDIUM | Act on it, but flag if results are unexpected |
| > 24 hours | LOW | Re-verify against source before acting |
| > 72 hours | EXPIRED | Treat as unverified hypothesis. Full re-verification required |

9. You MUST NOT act on EXPIRED facts without re-verification. There are no exceptions.

### Phase 3: Snapshot Creation

10. Write a context snapshot to `.docs/context/SNAPSHOT_<YYYYMMDD_HHMMSS>.md` using this exact format:

```markdown
## Session Snapshot
- **Created:** <ISO 8601 timestamp>
- **Agent Session:** <session identifier if available>

### Current State
- **Active Task:** TASK-XXX — <brief description>
- **Working Branch:** `<branch_name>`
- **Last Passing Commit:** `<short_hash>` — <commit message summary>
- **Test Status:** <PASSING / FAILING / UNKNOWN>

### Key Decisions Made
1. <Decision>: <Rationale> (Source: <file:line or discussion ref>)

### Facts Established
| Fact | Source | Verified At | Confidence |
|---|---|---|---|
| <factual claim> | <file:line> | <timestamp> | HIGH/MEDIUM/LOW |

### Superseded Information
| Original Fact | Superseded By | Date |
|---|---|---|
| <old claim> | <new claim with ref> | <date> |

### Open Questions
1. <Question> — Context: <why this matters, what's blocking>

### Next Steps
1. <Specific, actionable next step>
2. <Second step>

### Warnings
- <Anything the next session should be cautious about>
- <Known fragile areas, pending breaking changes, etc.>
```

11. Every field MUST be populated. If a section has no entries, write `None` — do NOT omit the section.

### Phase 4: Snapshot Triggers

12. You MUST write a snapshot at each of these boundaries:

| Trigger | Rationale |
|---|---|
| Session ending (natural or forced) | Preserve all accumulated context for the next session |
| Context window approaching capacity | Prevent silent knowledge loss from context truncation |
| Major milestone reached | Checkpoint progress so recovery doesn't lose completed work |
| Before any risky operation (rebase, large refactor, migration) | Enable rollback to known-good state if the operation fails |
| After resolving a complex bug | Capture the diagnosis and fix while the understanding is fresh |
| Branch switch | Different branches may have divergent state; snapshot the current one before switching |

13. When multiple snapshots exist, keep the 5 most recent. Archive older snapshots to `.docs/context/archive/` — do NOT delete them.

### Phase 5: Snapshot Hygiene

14. Before writing a new snapshot, read the previous snapshot. Carry forward any unresolved `Open Questions` and `Warnings`.
15. Explicitly mark any carried-forward items with `[CARRIED FROM <previous_snapshot_filename>]`.
16. If an open question has been resolved, move it to `Key Decisions Made` with the resolution.

---

## Anti-Rationalization Table

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "I'll remember the context; I don't need to write a snapshot." | You will not remember. Context dies at session boundaries. Snapshots are not memory aids — they are the only memory that persists. Write the snapshot. |
| "The session was short; nothing important happened." | Short sessions still make decisions, establish facts, and eliminate possibilities. Even negative results ("X doesn't work because Y") are valuable context. If you did anything, snapshot it. |
| "Writing snapshots slows down the actual work." | A 2-minute snapshot saves a 30-minute re-investigation next session. The time cost is asymmetric — investing now prevents compounding losses later. This is not overhead; this is the work. |
| "The previous snapshot is still mostly accurate." | 'Mostly accurate' means partially wrong. Stale snapshots poison future sessions with false confidence. Either verify and update it, or write a new one. There is no 'close enough.' |
| "I'll just re-derive the context from the code next time." | Re-derivation requires reading files, running tests, tracing dependencies — the same work you already did this session. Snapshots exist so you do the work once, not every time. |
| "Supersession is too verbose; I'll just update the fact in place." | Silent updates destroy audit trails. When a fact changes, the history of what was believed and when matters for debugging, understanding regressions, and preventing circular reasoning. Mark supersessions explicitly. |

---

## Evidence Requirement

Execution of this skill is verified by the existence and correctness of these artifacts:

| Artifact | Location | Verification Check |
|---|---|---|
| Context Snapshots | `.docs/context/SNAPSHOT_*.md` | At least one snapshot exists per session. Latest snapshot's git state matches actual `git status`. |
| Supersession Markers | Within snapshots and documentation | Any corrected facts show `[SUPERSEDED by <ref>]` on the original entry, not silent overwrites. |
| Confidence Annotations | `Facts Established` table in snapshots | Every fact has a `Verified At` timestamp and confidence level. No EXPIRED facts are acted upon without re-verification evidence. |
| Snapshot Continuity | `Open Questions` and `Warnings` sections | Unresolved items from previous snapshots are carried forward with `[CARRIED FROM ...]` tags. |
| Snapshot Archive | `.docs/context/archive/` | Older snapshots are archived, not deleted. At most 5 recent snapshots in the active directory. |

---

## Failure Modes

### 1. Context Amnesia
- **Symptom:** Agent starts every session from scratch, re-investigates solved problems, re-makes previously made decisions.
- **Detection:** No snapshot files exist, or the agent's first action is exploring the codebase without consulting snapshots.
- **Recovery:** Enforce the resumption protocol as Step 1 of every session. If no snapshot exists, create one immediately from current state before doing any work.

### 2. Stale Context Poisoning
- **Symptom:** Agent acts on outdated information from an old snapshot, introducing bugs or making wrong architectural decisions.
- **Detection:** Actions taken based on facts whose `Verified At` timestamp is >24 hours old without re-verification.
- **Recovery:** Apply confidence decay strictly. Any fact older than 24 hours must be spot-checked against source. Any fact older than 72 hours must be fully re-verified.

### 3. Information Hoarding
- **Symptom:** Snapshots grow to hundreds of lines, contain raw logs, full file contents, or stream-of-consciousness notes. Finding relevant information becomes harder than reading the code.
- **Detection:** Snapshot exceeds 100 lines. Sections contain prose paragraphs instead of structured entries.
- **Recovery:** Enforce the snapshot format strictly. Each entry should be one line. Move detailed analysis to separate files and link from the snapshot.

### 4. Phantom Memory
- **Symptom:** Agent "remembers" information about the project that came from training data or a different project, not from actual source code in this repository.
- **Detection:** Agent makes confident assertions that cannot be traced to a `Facts Established` entry with a file:line source.
- **Recovery:** Apply the Source Verification skill. Every claim about the codebase must be traceable to actual source. Unverified claims must be explicitly flagged as hypotheses.

### 5. Snapshot Divergence
- **Symptom:** Multiple snapshots exist with contradictory information about the same facts, and no supersession markers indicate which is authoritative.
- **Detection:** Comparing the two most recent snapshots reveals conflicting entries in `Facts Established` or `Current State`.
- **Recovery:** The most recent snapshot is authoritative by default, but BOTH facts must be re-verified against source. Add supersession markers to resolve the conflict explicitly.

---

## Integration Points

| Skill | Relationship |
|---|---|
| **Structural Cartography** | Architecture index (`INDEX.md`) is a primary reference for session resumption. Snapshots reference the architecture state; architecture docs provide the structural context snapshots build upon. |
| **Source Verification** | Every fact in the `Facts Established` table must satisfy Source Verification standards — traceable to a specific file and line. Confidence decay triggers re-verification through Source Verification protocols. |
| **Decision Journaling** | `Key Decisions Made` in snapshots are summarized from the decision journal. The journal holds full rationale; the snapshot holds the actionable summary. |
| **Assumption Logging** | Open questions and unverified facts in snapshots must be cross-referenced with the assumption log. An assumption resolved in one session should appear as a `Key Decision` in the next snapshot. |
| **Error Triage** | Post-mortem findings from error triage should be recorded in the snapshot's `Warnings` section to prevent regression in future sessions. |
