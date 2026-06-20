# 11 · Bounded Observation

> Safe, controlled interaction with the filesystem, terminal, and external processes — preventing context overflow, data loss, and runaway operations.

**Objective:** Every observation you make (file read, command execution, process interaction) MUST be bounded in size, duration, and blast radius so that you never flood your context, corrupt data, or leave the system in an unrecoverable state.

---

## Operational Protocol

### Phase 1 — Pre-Observation Checks

1. **Identify what you need to observe.** State the specific information you require in one sentence before executing any command or reading any file.
2. **Estimate output size.** If a command might produce >200 lines of output, you MUST pipe it through `head -n 200`, `tail -n 200`, or use pagination. Never dump unbounded output into your context.
3. **Check file size before reading.** Run `wc -l <file>` or `stat --printf='%s' <file>` before reading any file. If the file exceeds 500 lines or 50KB, use targeted reads (specific line ranges, `grep`, or `head`/`tail`) — never read the entire file.
4. **Know your working directory.** Run `pwd` or use absolute paths in every command. Relative paths under ambiguity are a protocol violation.

### Phase 2 — The Read-Before-Write Rule

5. **ALWAYS read the current state of a file before modifying it.** No exceptions. Read the relevant section, confirm you understand the existing content, then write.
6. **Never blindly overwrite.** If a file exists at your target path, you MUST read it first. If you cannot read it (permissions, binary), acknowledge this explicitly and justify why overwriting is safe.
7. **Verify target identity.** Before any write, confirm the file path is correct by inspecting at least the first 5 lines of the existing file.

### Phase 3 — Safe I/O Patterns

8. **Use atomic writes.** Write to a temporary file first (`<target>.tmp` or `mktemp`), then rename/move it to the final path. This prevents partial writes on disk.
   ```bash
   # Correct — atomic write
   cat > output.json.tmp << 'EOF'
   { "result": "data" }
   EOF
   mv output.json.tmp output.json

   # WRONG — direct write risks partial corruption on failure
   cat > output.json << 'EOF'
   { "result": "data" }
   EOF
   ```
9. **Flush and verify.** After writing, read back the file (or its checksum) to confirm the write succeeded.

### Phase 4 — Command Execution Discipline

10. **Capture both stdout AND stderr.** Use `2>&1` or explicit redirection for both streams. Critical errors appear only in stderr — ignoring it is a protocol violation.
    ```bash
    # Correct — captures both streams
    command arg1 arg2 2>&1 | head -n 100

    # Also correct — separate capture
    command arg1 arg2 > stdout.log 2> stderr.log
    ```
11. **Extract relevant information immediately.** After running a command, parse and extract only the data you need. Do NOT carry raw command output in working memory beyond the current step.
12. **Set timeouts on ALL external commands.** Use `timeout <seconds>` for any command that could hang. Default: 30 seconds for network commands, 60 seconds for builds, 10 seconds for simple file operations.
    ```bash
    timeout 30 curl -s https://api.example.com/status
    timeout 60 make build
    ```
13. **Kill hung processes.** If a command exceeds its timeout, confirm it was terminated. Check with `ps aux | grep <process>` and kill manually if needed. Never leave orphaned processes.

### Phase 5 — Destructive Command Safeguards

14. **Before ANY destructive command**, execute this three-step gate:

| Step | Action | Example |
|------|--------|---------|
| 1. Echo | Print the exact command you are about to run | `echo "Will run: rm -rf ./build/"` |
| 2. Verify | Confirm the target path/object is correct | `ls -la ./build/` to verify contents |
| 3. Backup | Ensure a backup or rollback mechanism exists | `cp -r ./build/ ./build.bak/` or confirm git status is clean |

15. **Destructive commands include but are not limited to:**
    - `rm`, `rm -rf`
    - `mv` (when overwriting)
    - `sed -i`, `perl -i` (in-place edits)
    - `git reset --hard`, `git clean -fd`
    - `DROP TABLE`, `DELETE FROM`, `TRUNCATE`
    - `chmod`/`chown` (recursive)
    - `dd`, `mkfs`
    - Any command with `--force` or `-f` flags

16. **Never use force flags without explicit justification.** If you use `-f`, `--force`, `--no-verify`, or `--skip-checks`, you MUST state in writing why the safeguard is being bypassed and what alternative protection exists.

### Phase 6 — The Observation Budget

17. **Each observation MUST consume fewer than 100 lines of context.** If you need more data, make multiple targeted observations, each under the 100-line cap.
18. **Apply the head/tail discipline.** For large outputs:
    - First lines: `head -n 50`
    - Last lines: `tail -n 50`
    - Specific range: `sed -n '100,150p'`
    - Pattern match: `grep -n "pattern" | head -n 20`
19. **Summarize, don't store.** After each observation, produce a 1–3 sentence summary of what you learned. Discard raw data from working memory.

---

## Anti-Rationalization Table

| Agent Excuse | Architectural Rebuttal |
|---|---|
| "The file is small enough to read entirely." | You do not know a file's size until you check. Run `wc -l` first. Files grow over time — a "small" file today may be 5000 lines tomorrow. The protocol exists to build the habit, not to handle today's edge case. |
| "I need the full output to understand the error." | No, you need the *relevant* output. Pipe through `grep -A5 'error\|fail\|exception'` or read the last 50 lines. Full output floods your context and actually *reduces* your ability to find the error. |
| "Atomic writes are overkill for a config file." | Partial writes corrupt config files. A half-written JSON or YAML file will crash the application on restart. The `tmp + mv` pattern costs 1 extra line and prevents catastrophic corruption. |
| "Setting timeouts slows me down." | A hung process that you never notice slows you down infinitely. The 2 seconds you spend adding `timeout` saves the 20 minutes you would spend debugging a zombie process or a blocked terminal. |
| "I already know what's in the file — I just wrote it." | Memory is unreliable. Another process, a concurrent agent, or a hook script may have modified the file since you last touched it. Read-before-write is non-negotiable. |
| "The force flag is fine here — I'm sure of the target." | Certainty is the precondition for catastrophe. The `-f` flag exists to bypass safety checks. If you bypass them, you absorb their responsibility. State your justification in writing or remove the flag. |

---

## Evidence Requirement

Correct execution of this skill produces these verifiable artifacts:

| Artifact | Verification Method |
|---|---|
| **Pre-read confirmation** | Your working log shows a file read immediately before every file write, with content acknowledgment |
| **Bounded output** | No single command output block in your context exceeds 100 lines. All large outputs show evidence of `head`, `tail`, `grep`, or pagination |
| **Atomic write pattern** | File writes use the `tmp + mv` pattern or equivalent. No direct overwrites of critical files |
| **Timeout usage** | Every external/network command includes a `timeout` prefix |
| **Destructive command gate** | Before each destructive command: the echo step, the verify step, and the backup step are all present in the log |
| **No orphaned processes** | A post-session `ps` check shows no processes spawned by the agent still running |

---

## Failure Modes

### 1. Context Flooding
- **Symptom:** Agent reads a 3000-line log file, loses track of its task, produces confused or contradictory output.
- **Detection:** Any single observation exceeding 200 lines in the working context.
- **Recovery:** Immediately discard the oversized content. Re-execute the observation with proper bounds (`head`, `tail`, `grep`). Restate the current objective from memory before proceeding.

### 2. Blind Write Corruption
- **Symptom:** Agent overwrites a file without reading it first; user-edited content, comments, or configuration is lost.
- **Detection:** A file write operation with no preceding read of the same file path in the session log.
- **Recovery:** Check git history or backup for the pre-write state. Restore from `git checkout -- <file>` or the backup copy. Re-apply changes with proper read-before-write.

### 3. Zombie Process Accumulation
- **Symptom:** Terminal becomes unresponsive or system resources spike. Background processes spawned by the agent continue running after the task is complete.
- **Detection:** Run `ps aux | grep -v grep | grep <agent-spawned-pattern>` and check for unexpected long-running processes.
- **Recovery:** Kill all orphaned processes with `kill -9 <pid>`. Audit the session for commands that were run without `timeout`. Add timeout wrappers retroactively.

### 4. Stderr Blindness
- **Symptom:** A command "succeeds" (exit code 0 or no stdout error) but writes critical warnings to stderr that the agent ignores, leading to downstream failures.
- **Detection:** Command output shows only stdout capture; stderr was not redirected or reviewed.
- **Recovery:** Re-run the command with `2>&1` or `2>stderr.log`. Read stderr output. Address any warnings or errors before proceeding.

### 5. Partial Write on Crash
- **Symptom:** Agent writes directly to a target file. A crash or timeout interrupts the write mid-stream, leaving a truncated or corrupted file.
- **Detection:** File size is unexpectedly small, file fails to parse, or file ends abruptly.
- **Recovery:** Restore from backup or git. Re-execute the write using the atomic `tmp + mv` pattern.

---

## Integration Points

| Connected Skill | Relationship |
|---|---|
| **Semantic Navigation** (12) | Navigation produces observations — every file read and search result must obey bounded observation limits. Navigation is the *what to observe*; this skill is the *how to observe safely*. |
| **Architecture-First** (01) | Architecture docs guide which files to observe. This skill ensures those observations don't flood context when architecture docs are large. |
| **Checkpointing** (04) | Destructive command safeguards require a clean checkpoint before execution. Bounded observation ensures checkpoints capture actual file state via read-before-write. |
| **Test-Driven Validation** (02) | Test execution produces terminal output that must be bounded. Long test suites MUST have output piped through filters to stay within the observation budget. |
| **Failure Recovery** | When recovering from failures, the temptation to dump full logs is highest. This skill is most critical during recovery — maintain observation discipline even under pressure. |

---

## Quick Reference Checklist

Before every observation, confirm:

- [ ] I stated what specific information I need
- [ ] I checked the file size / estimated the output length
- [ ] I am using absolute paths or have verified my working directory
- [ ] I am capturing both stdout and stderr
- [ ] My output will be under 100 lines of context
- [ ] If writing: I read the current state of the target file first
- [ ] If destructive: I completed the echo → verify → backup gate
- [ ] I set a timeout on any command that could hang
- [ ] I summarized the observation result in 1–3 sentences
