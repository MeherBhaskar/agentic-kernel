# User Escalation Protocol

**Objective:** Safely interrupt autonomous execution to escalate critical blockers, ambiguities, or destructive decisions to the human user.

---

## Operational Protocol

1. **The Escalation Threshold:**
   You MUST halt execution and escalate to the user if you encounter:
   - A destructive action (e.g., dropping a production database, deleting uncommitted files).
   - An unresolvable dependency conflict that requires downgrading core libraries.
   - A fundamental contradiction in the requirements discovered mid-execution.
   - A Third-Strike Failure (as defined in Adaptive Protocols) where the architecture needs a complete rewrite.

2. **The Escalation Format:**
   When escalating, your message to the user MUST follow this exact structure:
   - **[BLOCKED]** or **[DECISION REQUIRED]** header.
   - **Context:** 1-2 sentences explaining exactly what you were doing.
   - **The Blocker:** 1-2 sentences explaining exactly why you stopped.
   - **Options:** Present 2-3 concrete paths forward. Give your recommendation.
   - **Question:** A direct, unambiguous question asking the user which path to take.

3. **Example Escalation:**
   ```markdown
   ### [DECISION REQUIRED]: Dependency Conflict
   **Context:** I am attempting to install `package-x` for the new feature.
   **The Blocker:** `package-x` requires `lib-y v2.0`, but our project currently uses `lib-y v1.0`. Upgrading `lib-y` might break the existing authentication module.
   **Options:**
   1. Upgrade `lib-y` and run the test suite to fix any downstream auth breaks. (Recommended)
   2. Find an alternative to `package-x` that supports `lib-y v1.0`.
   3. Refactor the auth module first.

   Which path would you like me to take?
   ```

4. **The "No Silent Halts" Rule:**
   Never stop execution without explicitly telling the user *why* you stopped and *what* you need from them. Do not let the task simply end in a failure state without prompting for human intervention.

---

## Anti-Rationalization Table

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "I didn't want to bother the user, so I just picked an option." | Guessing on architectural pivot points or destructive actions is forbidden. The cost of interrupting the user is lower than the cost of reverting a catastrophic assumption. Escalate. |
| "I gave the user a status update but didn't ask a clear question." | A status update is not an escalation. If you need the user's input, you must force a decision by giving concrete options and asking a direct question. |
