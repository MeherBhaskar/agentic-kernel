# Phase 1 Director: Mission Synthesis

**Objective:** Serve as the entrypoint for all Phase 1 operations, evaluating incoming requests and orchestrating the distillation of requirements and strategic decomposition of tasks before any execution begins.

---

## The Phase Router

When entering Phase 1, you MUST execute the following sequence:

1. **Ingest & Orient**
   - Read the raw user request or issue ticket.
   - If the request is a simple bug fix, execute `01_requirement_distillation.md` focusing on reproduction steps.
   - If the request is a feature/epic, execute `01_requirement_distillation.md` focusing on edge cases and scope boundaries.

2. **Decompose & Plan**
   - Once a specification is complete, execute `02_strategic_decomposition.md`.
   - Transform the spec into vertical, verifiable slices.
   - Output the definitive `PLAN.md`.

3. **Phase Exit Gate**
   - Do NOT exit Phase 1 until `PLAN.md` exists and at least one task is ready to be marked `[IN PROGRESS]`.
   - Hand off to the **Phase 2 Director (Execution Engine)**.

## Phase Interruption Rules
- If during Phase 2/3 you discover a fundamental requirement flaw, return to this director and re-trigger `01_requirement_distillation.md`.
