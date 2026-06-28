<div align="center">

# Agent Rigor 
### **An Engineering Discipline Framework for AI Coding Assistants**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge)](http://makeapullrequest.com)
[![Platform Agnostic](https://img.shields.io/badge/Platform-Agnostic-orange.svg?style=for-the-badge)](#platform-agnostic)
[![GitHub last commit](https://img.shields.io/github/last-commit/MeherBhaskar/agent-rigor?style=for-the-badge)](https://github.com/MeherBhaskar/agent-rigor/commits/main)
[![arXiv](https://img.shields.io/badge/arXiv-2606.22678-b31b1b.svg?style=for-the-badge)](https://arxiv.org/abs/2606.22678)

<br>

*Help your AI agent adopt software engineering best practices directly into its workflow.*

<img src="assets/demo.svg" width="100%" alt="Agent Rigor Demo">

[The Problem](#the-problem-undisciplined-developer-syndrome) •
[Quickstart](#quickstart-in-2-minutes) •
[Core Philosophy](#core-philosophy) •
[What's Inside](#whats-inside-the-skills-library) •
[Evaluation](#evaluation)

<br>
<hr>
</div>

## The Problem: "Undisciplined Developer Syndrome"

AI coding agents often struggle not from a lack of intelligence, but from a lack of **engineering discipline**. Left to their own devices, agents typically:
- Skip planning and jump straight to implementation.
- Write plausible-looking code that misses edge cases.
- Get trapped in "doom loops" (fix-forward spirals) instead of backing out of bad approaches.
- Suffer from context amnesia, forgetting lessons learned between sessions.

## The Solution: Agent Rigor

**Agent Rigor** is a framework of modular Agent Skills designed to encourage mature, battle-tested software engineering practices. It provides structured instructions, verification steps, and safeguards that guide agents toward empirical discipline at every step.

**Agents evaluated with agent-rigor scored 36% higher on process discipline and 30% higher on outcome correctness than baseline.**

---

## Quickstart in 2 Minutes

Get Agent Rigor running in your project quickly.

### 1. Bootstrap Your Project
Run this in your project root:
```bash
curl -sSL https://raw.githubusercontent.com/MeherBhaskar/agent-rigor/main/install.sh | bash
```
*(Or manually clone this repo into an `.agents/` directory).*

### 2. Command Your Agent
Just drop this prompt to your AI:
> "I need to build [feature]. Read `.agents/SYSTEM_CORE.md` and begin."

Your agent will now plan, execute, review, and persist its context methodically.

---

## Platform Agnostic

Agent Rigor is pure markdown. It works natively with standard AI tools:

| Agent / IDE | Integration Method |
| :--- | :--- |
| **Cursor** | Point to `.agents/SYSTEM_CORE.md` in your `.cursorrules` or `.mdc` files. |
| **Claude Code** | Include a reference in your `CLAUDE.md`. |
| **GitHub Copilot** | Reference in `.github/copilot-instructions.md`. |
| **Gemini CLI** | Include in `./AGENTS.md`. |
| **Aider** | Pass via `--read .agents/SYSTEM_CORE.md`. |

*Checkout the [`examples/`](./examples) folder for ready-to-use templates.*

---

## Core Philosophy

1. **Actionable Protocols**: Instructions should be verifiable steps with exit criteria.
2. **Empirical Sovereignty**: Claims require evidence; tests should pass.
3. **Atomic State Transitions**: Code ideally moves only between known-good states.
4. **Anti-Rationalization**: Anticipates common AI shortcuts (e.g., skipping tests).
5. **Dynamic Modularity**: Triggers only necessary skills to save context tokens.

---

## Documentation & Resources

- [Quickstart Guide](QUICKSTART.md) — Step-by-step setup
- [Cheatsheet](core/CHEATSHEET.md) — Quick reference for daily use
- [Context Management](core/CONTEXT_MANAGEMENT.md) — Understanding the modular architecture
- [Contributing](CONTRIBUTING.md) — Help us build smarter agents

---

## What's Inside: The Skills Library

Agent Rigor includes a library of 18 specialized Agent Skills. The **Apex Kernel** routes the agent to the appropriate **Phase Director**, loading only the necessary skills to help manage the context window.

**Phase 1: Mission Synthesis**
- **Requirement Distillation** - Extracts technical specifications from user requests.
- **Strategic Decomposition** - Breaks down requirements into independent, actionable sub-tasks.
- **Interrogation Protocol** - Questions the user to resolve ambiguities before writing code.

**Phase 2: Execution Engine**
- **Convergent Iteration** - Encourages code changes to move steadily toward the goal without regressions.
- **State Checkpoint Protocol** - Suggests committing known-good project states to allow rollbacks.
- **Incremental Proof Cycles** - Promotes continuous micro-testing during implementation.

**Phase 3: Verification Matrix**
- **Pentagonal Audit** - A 5-point code review evaluating security, performance, edge cases, state bounds, and types.
- **Entropy Reduction** - Cleans up technical debt, commented-out code, and temporary logs.

**Phase 4: Cognitive Persistence**
- **Structural Cartography** - Maintains a map of the codebase for efficient semantic navigation.
- **Context Lifecycle** - Manages the ingestion and eviction of data in the agent's context window.
- **Source Verification** - Encourages citing actual codebase locations rather than guessing paths.

**Phase 5: Interface Protocols**
- **Bounded Observation** - Helps prevent endlessly reading irrelevant files.
- **Semantic Navigation** - Promotes targeted file searches.
- **User Escalation** - Pauses the agent and asks the human when critical decisions are needed.

**Phase 6: Adaptive Protocols**
- **Recursive Self-Correction** - A protocol that activates when an agent gets stuck on a failing test suite.
- **Scope Containment** - Helps prevent "scope creep" by bounding the agent's actions to the original plan.
- **Experiential Consolidation** - Extracts lessons learned from failures for future tasks.
- **Cascade Orchestration** - Manages multi-step failures while maintaining the original goal intent.

---

## Evaluation

Evaluated in RigorBench (arXiv:2606.22678) across 100 tasks and 4 harnesses.

| Task Category | Baseline ReAct | Superpowers | Agent-Skills | **Agent-Rigor** |
| :--- | :---: | :---: | :---: | :---: |
| **Plan-Then-Build** | 0.52 | 0.51 | 0.48 | **0.60** |
| **Know When to Fold** | 0.49 | 0.53 | 0.48 | **0.62** |
| **Verify-Or-Die** | 0.46 | 0.46 | 0.46 | **0.63** |
| **Doom Loop Gauntlet** | 0.45 | 0.45 | 0.45 | **0.55** |
| **Don't Break the Build** | 0.45 | 0.44 | 0.44 | **0.64** |

> **Key Finding:** Agent-Rigor scored 0.53 vs 0.39 baseline on the RigorBench process quality composite — a 36% relative improvement.

---

<div align="center">

### Support the Project
If you find Agent Rigor helpful for your workflows, we'd appreciate a star!

[![GitHub stars](https://img.shields.io/github/stars/MeherBhaskar/agent-rigor?style=social)](https://github.com/MeherBhaskar/agent-rigor/stargazers)

*Built collaboratively for the future of Autonomous Software Engineering.*

</div>
