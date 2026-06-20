# Phase 2 Director: Execution Engine

**Objective:** Serve as the entrypoint for all Phase 2 operations, orchestrating the implementation of tasks defined in `PLAN.md` through tight, test-driven, git-backed iteration loops.

---

## The Phase Router

When entering Phase 2 (usually handed off from Phase 1), you MUST execute the following loop for the active task:

1. **Test-First Initialization**
   - Execute `05_incremental_proof_cycles.md`.
   - Write a failing test that defines the success criteria for the current `PLAN.md` task.

2. **Iterative Implementation**
   - Execute `03_convergent_iteration.md`.
   - Enter the Reason-Act-Observe loop to make the test pass.
   - Monitor for divergence or 3-strike failures (if triggered, call Adaptive Protocols).

3. **State Checkpointing**
   - Upon a passing test suite, execute `04_state_checkpoint_protocol.md`.
   - Commit the working state atomically.
   - If the task failed fundamentally, execute the hard revert defined in the protocol.

4. **Phase Exit Gate**
   - Do NOT exit Phase 2 until the code is committed and tests are green.
   - Hand off to the **Phase 3 Director (Verification Matrix)**.
