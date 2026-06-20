# Phase 6 Director: Adaptive Protocols

**Objective:** Serve as the entrypoint for all Phase 6 operations, acting as the system's "immune system" to detect failures, manage scope, consolidate learnings, and orchestrate complex cascades.

---

## The Phase Router

Phase 6 operates as an overlay on the entire Agentic Kernel. These skills are triggered by anomalies or meta-level requirements:

1. **Stall & Doom Loop Resolution**
   - Triggered continuously during Phase 2 (Execution).
   - Execute `13_recursive_self_correction.md` if an approach fails 3 times or divergence is detected.

2. **Scope Defense**
   - Triggered when starting any task or when discovering adjacent issues.
   - Execute `14_scope_containment.md` to enforce the touch audit and log deferred observations.

3. **Knowledge Consolidation**
   - Triggered after major failures, milestones, or 3-strike events.
   - Execute `15_experiential_consolidation.md` to extract reusable procedural rules and store them in `.docs/learned_rules/`.

4. **Meta-Orchestration**
   - Triggered at the absolute beginning of a complex, multi-task goal.
   - Execute `16_cascade_orchestration.md` to act as the overarching conductor, tracking progress across all other phases.

5. **Phase Exit Gate**
   - Adaptive protocols interrupt the standard flow, correct the state, and then return execution to the phase that triggered them.
