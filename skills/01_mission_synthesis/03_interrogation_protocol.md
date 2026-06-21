# Interrogation Protocol (The "Grill Me" Skill)

**Objective:** Conduct a relentless, interactive interview with the user to sharpen a plan, resolve ambiguities, and pressure-test architectural decisions *before* writing any code.

---

## Operational Protocol

1. **Trigger Condition:** Execute this protocol when the user explicitly requests to be "grilled" (e.g. `/grill-me`), or when `01_requirement_distillation.md` yields too many Open Questions to safely proceed autonomously.

2. **The Golden Rule of Interrogation:**
   - **Ask ONE question at a time.** Never present the user with a bulleted list of 5 questions.
   - Wait for the user's answer before asking the next question.
   - You are the driver; you keep asking questions until the plan is airtight.

3. **Interrogation Axes:**
   Focus your questions on the following pressure points:
   - **Edge Cases:** "What happens if [X] fails?" or "What should the system do if the user inputs [Y]?"
   - **Scope Boundaries:** "Is [Z] required for the MVP, or is it out of scope?"
   - **Architecture:** "Are we prioritizing read speed or write speed for this feature?"
   - **Failure Modes:** "How should we handle API rate limits here?"

4. **Iterative Refinement:**
   - After the user answers, briefly validate their answer.
   - Immediately follow up with the *next* logical question.
   - Do NOT start writing implementation code during the interrogation phase.

5. **Exit Condition:**
   - The interrogation ends when you have zero remaining Open Questions regarding the system's core behavior, OR when the user explicitly says "stop grilling" or "let's build it".
   - Upon exit, immediately generate the final Specification Document (as defined in `01_requirement_distillation.md`).

---

## Anti-Rationalization Table

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "I'll just ask all 5 questions at once to save time." | Batching questions overwhelms the user. They will answer the easiest one and ignore the rest, leaving ambiguities unresolved. Ask ONE question at a time. |
| "The user gave a vague answer, I'll just guess the rest." | The entire point of the Interrogation Protocol is to eliminate guessing. If the answer is vague, ask a clarifying question. |
