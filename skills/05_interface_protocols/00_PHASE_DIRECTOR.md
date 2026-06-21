# Phase 5 Director: Interface Protocols

**Objective:** Serve as the entrypoint for all Phase 5 operations, providing the foundational layer for safe environment interaction, terminal usage, and codebase traversal.

---

## The Phase Router

Phase 5 is the **Support Layer**. It does not exist in the sequential flow of Phases 1-4; rather, it dictates *how* actions in other phases are performed.

Whenever you interact with the environment, route your approach through these skills:

1. **Reading & Searching Code**
   - Execute `12_semantic_navigation.md`.
   - Never use brute-force grep. Follow the navigation hierarchy (Architecture -> Directories -> Files -> Symbols -> Text).

2. **Executing Commands & I/O**
   - Execute `11_bounded_observation.md`.
   - Enforce truncation, atomic writes, and the read-before-write rule.
   - Apply the destructive command safeguards before any state-altering shell operation.

3. **Human Collaboration & Blockers**
   - Execute `13_user_escalation.md`.
   - Safely halt execution and present structured options when hitting critical blockers or unresolvable ambiguities mid-execution.

4. **Phase Exit Gate**
   - These are constant operational constraints. They apply immediately and universally across all other phases.
