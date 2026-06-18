# kb/ — base of known issues (growing)

`known-issues.sh` — a registry of common Linux problems with a detector and a safe
repair. This is "fixes for all the bugs" in honest form: not "every bug in the
world," but a **growing set of common problems** that **learns by itself** from
what it couldn't fix.

## Learning cycle
```
fix didn't fix X  →  entry in ~/.local/state/kit-claude/unfixed.jsonl
                  →  "claude, work through unfixed"  →  root cause found
                  →  new check_X() in known-issues.sh  →  base is bigger
```

## How to add a new check (Claude does this)
1. Read `unfixed.jsonl` — fields `problem`, `tried`, `detail`.
2. Understand the root cause (not the symptom).
3. Write a function:
```bash
check_MY_NAME() {
  section "Human-readable title"
  if <all good>; then ok "ok"; return 0; fi
  warn "what's wrong and why it matters"
  run_root "why root is needed" green|yellow|red <command>   # repair via the safe path
  if <check that it got fixed>; then ok "fixed"; return 0; fi
  log_unfixed "label" "what was tried" "details"; return 1
}
```
4. Add the function name to the `KIT_CHECKS` array (execution order).

## Rules
- Fix only **safe** things automatically; risky ones (🟡/🔴) — via
  `run_root … yellow|red`, which always asks for confirmation.
- Every repair is reversible or has a clear rollback. Not sure — better `log_unfixed`
  and let the human/Claude decide than break something.
- Don't duplicate existing checks; read the whole file first.
