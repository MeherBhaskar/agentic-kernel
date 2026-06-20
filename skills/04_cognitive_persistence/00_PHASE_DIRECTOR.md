# Phase 4 Director: Cognitive Persistence

**Objective:** Serve as the entrypoint for all Phase 4 operations, managing long-term memory, context handoffs, and architectural documentation to ensure the agent's intelligence compounds over time.

---

## The Phase Router

Phase 4 operations are triggered continuously at specific lifecycle moments:

1. **Session Start / Information Gathering**
   - Execute `09_context_lifecycle.md` to read the latest context snapshot.
   - Execute `10_source_verification.md` before trusting any documentation or prior knowledge about the codebase.

2. **Post-Implementation Documentation**
   - After Phase 3 completes a structural change (new modules, new entry points), execute `08_structural_cartography.md` to update the `.docs/architecture/` maps.

3. **Session Handoff / Boundary**
   - When a session is ending, context is overflowing, or a major milestone is reached, execute `09_context_lifecycle.md` to generate a Context Snapshot for the next session.

4. **Phase Exit Gate**
   - Phase 4 is a persistent background state. It exits back to the system orchestrator when memory tasks are complete.
