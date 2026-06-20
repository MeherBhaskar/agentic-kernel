# Framework: Experiential Consolidation

**Objective:** Transform raw execution history (git logs, progress entries, failure records) into distilled, reusable procedural knowledge that improves agent performance over time — enabling the system to learn from its own experience.

---

## The Problem

Agents are stateless by default. Every session starts from zero. Mistakes made in session 1 are repeated in session 5. Solutions discovered through painful iteration are forgotten by the next context window. This makes autonomous agents incapable of compounding improvement — they are perpetual beginners.

Experiential Consolidation solves this by providing a structured process for:
1. **Extracting** patterns from execution history
2. **Distilling** them into reusable rules
3. **Persisting** them in a format the agent reads at session start
4. **Validating** that the rules actually improve outcomes

---

## Operational Protocol

### 1. Trigger Conditions

Consolidation runs at these moments:

| Trigger | What to Consolidate |
|---------|-------------------|
| After a Three-Strike rollback (Skill 13) | What approach failed and why. What approach worked instead |
| After completing a major milestone | What patterns emerged that should be generalized |
| After a session with >3 deferred observations | Common issues that keep appearing in this codebase |
| After discovering a non-obvious environment behavior | Tool quirks, library gotchas, platform-specific behavior |
| On explicit user request ("learn from this") | Whatever the user indicates should be remembered |

### 2. Extract Raw Observations

Review the following sources:
- `progress_log.md` — especially FAILURE and ROLLBACK entries
- `git log --oneline -20` — recent commit history
- Deferred observations from Skill 14
- Any error messages that required non-obvious solutions

### 3. Distill into Procedural Rules

Transform raw observations into actionable rules using this format:

```markdown
## Rule: [Descriptive Title]
- **Context:** [When does this rule apply?]
- **Trigger:** [What situation activates this rule?]
- **Action:** [What should the agent do?]
- **Rationale:** [Why does this work? What failure does it prevent?]
- **Source:** [Reference to the original incident — task ID, date, or commit hash]
- **Confidence:** HIGH | MEDIUM | LOW
- **Last Validated:** [date]
```

### 4. Categorize and Store

Write rules to `.docs/learned_rules/` organized by category:

```
.docs/learned_rules/
├── codebase_patterns.md      # Patterns specific to THIS codebase
├── library_gotchas.md        # Non-obvious library/framework behaviors
├── environment_quirks.md     # Build system, deployment, tooling notes
├── anti_patterns_discovered.md  # Things that consistently fail
└── effective_strategies.md   # Approaches that consistently work
```

### 5. Validate Existing Rules

Every 5th session (or weekly), review existing rules:

| Check | Action |
|-------|--------|
| Is this rule still relevant? | If the codebase has changed and the rule no longer applies, mark as `[ARCHIVED]` |
| Has this rule been contradicted? | If a rule was proven wrong by subsequent experience, mark as `[SUPERSEDED]` with reference |
| Has this rule been applied? | If a rule hasn't been relevant in 10+ sessions, consider archiving |
| Is this rule too specific? | Generalize overly narrow rules. Archive duplicate rules |

### 6. Session Startup Integration

At the beginning of every session, the agent MUST:

1. Read `.docs/learned_rules/` files that are relevant to the current task
2. Apply HIGH and MEDIUM confidence rules automatically
3. Treat LOW confidence rules as suggestions to verify before applying

---

## The Consolidation Template

When writing a new learned rule, use this mental model:

```
I was working on [context].
I tried [approach A], which failed because [reason].
I then tried [approach B], which also failed because [reason].
What actually worked was [approach C] because [insight].

The generalizable lesson is: [rule].
```

### Example

```markdown
## Rule: Database Migration Order Matters
- **Context:** Adding new columns with foreign key constraints
- **Trigger:** When creating a migration that adds a FK to a table that is also being modified
- **Action:** Split into two migrations: (1) add column as nullable without FK, (2) backfill data, (3) add FK constraint
- **Rationale:** Single-migration approach fails on large tables because the FK check locks the referenced table during the entire ALTER
- **Source:** TASK-047, 2024-03-15, commit a3f2c91
- **Confidence:** HIGH
- **Last Validated:** 2024-03-15
```

---

## Anti-Rationalization

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "I'll remember this for next time." | You will not. You are stateless. If it's not written to disk, it does not exist in your next session. |
| "This lesson is too specific to this one case." | Then generalize it. The specific case is an instance of a pattern. Extract the pattern. |
| "The rules file is getting too long." | Then categorize, archive stale rules, and prune. A long rules file that's well-organized is far better than no rules file. |
| "I don't have time to consolidate, the next task is urgent." | Consolidation is an investment with compound returns. Skipping it guarantees you will waste MORE time repeating past mistakes. |
| "The rule seems obvious." | It was not obvious when you failed at it. If it were obvious, you wouldn't have needed 3 attempts. Write it down. |

---

## Evidence Requirement

1. **Learned rules directory exists** — `.docs/learned_rules/` is populated and maintained
2. **Rules reference source incidents** — Each rule traces back to a specific failure or discovery
3. **Rules are applied** — Progress log entries reference learned rules that influenced decisions
4. **Stale rules are archived** — Rules have `Last Validated` dates and get reviewed periodically

---

## Failure Modes

| Failure | Detection | Recovery |
|---------|-----------|----------|
| No consolidation ever happens | `.docs/learned_rules/` is empty after 10+ tasks | Schedule consolidation as an explicit task |
| Rules are written but never read | Progress log never references learned rules | Add rule-reading to session startup checklist |
| Rules become stale and misleading | Rules reference modules/patterns that no longer exist | Schedule periodic rule validation |
| Over-consolidation (too many trivial rules) | Rules file is 500+ lines of obvious advice | Prune: if a competent developer would know this, remove it |
| Rules conflict with each other | Two rules give contradictory advice | Resolve conflict, archive the losing rule |

---

## Integration Points

- **Recursive Self-Correction (Skill 13):** Three-strike events are the primary input for consolidation
- **Context Lifecycle (Skill 09):** Context snapshots trigger consolidation at session boundaries
- **Source Verification (Skill 10):** Learned rules about library behavior must be re-verified against actual source
- **Structural Cartography (Skill 08):** Codebase-specific rules complement architectural maps
- **All Skills:** Learned rules can override or extend any skill's default behavior for the specific codebase
