# Context Management & Skill-Based Architecture

**Objective:** Prevent "context rot" and instruction neglect by strictly controlling how much of the Agent Rigor is loaded into the agent's working memory at any given time.

---

## The Danger of Context Collapse

If an agent loads all 20+ skill files into its context window simultaneously, it will suffer from **instruction neglect**. The noise ratio becomes too high, and the agent will revert to its baseline training behaviors, ignoring the strict protocols defined in this repository.

To prevent this, Agent Rigor uses **Skill-Based Architecture** — an architecture that reveals instructions only when they are actively needed by triggering specific Agent Skills.

---

## The 3-Layer Context Architecture

### Layer 1: The Apex Kernel (Always-On)
**File:** `SYSTEM_CORE.md`  
**When to load:** Always. This should be injected via system prompt, `.cursorrules`, or `CLAUDE.md`.  
**Purpose:** Defines the non-negotiable laws and the overarching Phase Router. It tells the agent *where* to go, but not the deep details of *how* to execute the skills. It must remain under 150 lines.

### Layer 2: Phase Directors (Just-in-Time Routing)
**Files:** `skills/**/00_PHASE_DIRECTOR.md`  
**When to load:** Only when the agent enters that specific phase.  
**Purpose:** Once the Apex Kernel routes an agent to Phase 2, the agent reads the Phase 2 Director. This director acts as the local orchestrator, explaining which L3 skills to use and the exit criteria for the phase.  
*Rule: When moving from Phase 2 to Phase 3, the agent should ideally drop the Phase 2 Director from its active context to save tokens.*

### Layer 3: Execution Skills (Task-Specific)
**Files:** `skills/**/[01-16]_*.md`  
**When to load:** ONLY when the Phase Director explicitly instructs the agent to execute that skill.  
**Purpose:** The deep, detailed operational protocols, anti-rationalization tables, and evidence requirements.   
*Rule: Once a skill is completed (e.g., PLAN.md is written), the agent drops `02_strategic_decomposition.md` from its active thought process.*

---

## Implementation by Platform

### For General LLMs & CLI Agents (Claude Code, Antigravity)

Your initial prompt or base instruction file should ONLY contain the contents of `SYSTEM_CORE.md`. Add this strict instruction to the bottom:

> **SKILL-BASED LOADING PROTOCOL:** Do NOT read the entire `skills/` directory at once. When routed to a Phase, read ONLY the `00_PHASE_DIRECTOR.md` for that phase. When the director tells you to execute a specific skill, read ONLY that specific `.md` file.

### For Cursor IDE (`.mdc` files)

Cursor handles skill-based loading natively using `.mdc` file metadata. To implement Agent Rigor in Cursor:

1. Create `.cursor/rules/00-apex.mdc`:
   - `alwaysApply: true`
   - Paste the contents of `SYSTEM_CORE.md`

2. Create phase-specific rules (e.g., `.cursor/rules/02-execution.mdc`):
   - `alwaysApply: false`
   - Include the contents of `00_PHASE_DIRECTOR.md` and the L3 skills for that phase.
   - Use `globs` to trigger it contextually (e.g., trigger Execution Engine when modifying `*.py` or `*.ts` files).
   - Use descriptive text so Cursor's intent routing pulls it in when the user says "implement this task".

3. Task-specific rules (e.g., `05-interface.mdc`):
   - Triggered manually via `@ruleName` or when specific shell commands are detected.

---

## The "Read-and-Drop" Discipline

As an AI assistant, you must actively manage your own context window. 
- When you finish writing the `PLAN.md`, you no longer need the strategic decomposition rules in your immediate focus. 
- When you are writing a test, you do not need the architectural graphing rules.

**Rely on the outputs (the artifacts) rather than keeping the instructions in memory.** The `PLAN.md` and the `progress_log.md` are your external memory. Use them to keep your active context clean, fast, and highly obedient.
