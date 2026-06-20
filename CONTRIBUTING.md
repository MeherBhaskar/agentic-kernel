# Contributing to Agentic Kernel

Thank you for your interest in improving Agentic Kernel! This framework aims to be the universal operating system for autonomous coding agents, bringing engineering discipline to AI-driven development.

## Core Philosophy

Before contributing, please understand the core philosophy:

1. **Actionable Protocols**: We don't write essays for agents to read. We write structured protocols with explicit exit criteria and verifiable evidence.
2. **Actionability**: A junior developer (or AI agent) should be able to read any skill file and know *exactly* what to do next without ambiguity.
3. **Pessimistic Design**: We assume agents will try to take the shortest path, make wrong assumptions, and skip steps. Our protocols are designed to detect and block these failure modes.

## Adding a New Skill

If you want to add a new skill to the framework, please follow these steps:

1. **Identify the Phase**: Determine which L2 Phase your skill belongs in (Mission Synthesis, Execution Engine, Verification Matrix, Cognitive Persistence, Interface Protocols, or Adaptive Protocols).
2. **Draft the Skill File**: Create the Markdown file in the appropriate directory using the naming convention `XX_descriptive_name.md` (where XX is the next sequential number).
3. **Follow the Template**: Every skill MUST include the following sections:
   - **Objective**: One sentence explaining the purpose.
   - **Operational Protocol**: Numbered, imperative steps the agent must execute.
   - **Anti-Rationalization**: A table of common agent excuses and architectural rebuttals.
   - **Evidence Requirement**: What physical artifact proves the skill was executed.
   - **Failure Modes**: Common ways the skill fails and how to recover.
   - **Integration Points**: Links to other skills in the kernel.
4. **Test the Skill**: Run the skill with a real agent on a real codebase. Did it follow the protocol? Did it try to rationalize skipping steps? Iterate on the wording until the agent consistently complies.

## Improving Existing Skills

We welcome improvements to existing skills! When modifying a skill:
- Keep the language imperative ("You MUST", not "You should").
- Ensure the steps remain verifiable.
- Add new failure modes or rationalizations you've observed agents making in the wild.

## Pull Request Process

1. Fork the repository and create your branch from `main`.
2. Make your changes, ensuring they align with the Core Philosophy.
3. Update the `README.md` if you are adding or renaming a skill.
4. Ensure your commit messages follow the conventional commits format (e.g., `feat(skills): add 17_database_migration_protocol`).
5. Open a Pull Request with a clear description of the problem your change solves and how you tested it with an agent.

## Issues and Discussions

If you discover a new failure mode or an interesting pattern for agent behavior, please open an Issue to discuss it! We want to collect real-world data on how agents fail and how we can constrain them effectively.
