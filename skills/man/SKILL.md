---
name: man
description: Read and analyze man pages for CLI tools. Compares flags you actually use against the full manual — surfaces new, useful, or unknown options. Use when the user asks about a command's options, wants to learn a tool deeper, or is testing/debugging CLI commands.
argument-hint: "[command] [subcommand]"
allowed-tools: "Bash(man *) Bash(* --help) Bash(* -h) Bash(command -v *) Bash(which *) Bash(type *)"
---

# Man Page Analysis

Read the man page for `$ARGUMENTS`.

## Steps

1. **Get the man page:**
   ```
   man $ARGUMENTS
   ```
   If no man page exists, fall back to `$ARGUMENTS --help` or `$ARGUMENTS -h`.

2. **Parse and present** a concise summary:
   - **Synopsis** — usage pattern
   - **Key options** — the most useful flags grouped by purpose
   - **New/notable options** — flags added in recent versions that users often miss

3. **If the user has a command in context** (from conversation, shell history, or a script):
   - List every flag/option used in that command
   - For each flag: show what it does (from the manual)
   - **Diff against full manual**: highlight flags the user is NOT using that are relevant to their task
   - Flag any deprecated options the user is using

4. **Version-aware notes:**
   - Check installed version: `$ARGUMENTS --version` or equivalent
   - Note if certain flags are version-specific

## Output format

Keep it scannable:
- Group flags by category (output, filtering, behavior, etc.)
- Bold the flag, then short description
- Mark new/uncommon flags with `[!]`
- Mark deprecated flags with `[deprecated]`

## Example interaction

User runs: `/man rsync`
→ Show rsync synopsis + key flags grouped by purpose + notable flags they might not know about.

User has `rsync -avz --progress` in context, runs `/man rsync`
→ Explain -a, -v, -z, --progress, THEN show useful flags they're missing for their use case (e.g., --partial, --info=progress2, --mkpath).
