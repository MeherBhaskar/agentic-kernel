# Phase 3 Director: Verification Matrix

**Objective:** Serve as the entrypoint for all Phase 3 operations, enforcing rigorous quality, security, and complexity reviews before any implemented task is finalized.

---

## The Phase Router

When entering Phase 3 (handed off from Phase 2), you MUST execute the following sequence:

1. **Mandatory Audit**
   - Execute `06_pentagonal_audit.md`.
   - Review the newly committed diff across Correctness, Readability, Architecture, Security, and Performance.
   - If CRITICAL findings exist, return to Phase 2 to fix them, then return here.

2. **Complexity Management (Conditional)**
   - If the audit identifies high cyclomatic complexity, or if existing code was difficult to work with during Phase 2, execute `07_entropy_reduction.md`.
   - Simplify the code while preserving exact behavior via characterization tests.

3. **Phase Exit Gate**
   - Do NOT exit Phase 3 until the audit is logged in `progress_log.md` with zero open CRITICAL findings.
   - Hand off to the **Phase 4 Director (Cognitive Persistence)** to record learnings and update architecture, OR loop back to Phase 2 for the next task in `PLAN.md`.
