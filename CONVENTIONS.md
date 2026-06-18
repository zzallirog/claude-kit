# CONVENTIONS — how things are done here

This is a ported working method (simplified, without the personal clutter). Not
mandatory, but if you adopt it, life gets a lot easier. Claude will help you set
all of this up at the "conventions" STEP of the bootstrap.

## 1. Fish — the default shell
The terminal is `fish` (smart suggestions, autocompletion from history, humane
syntax). Installation and setting it as default happen via the bootstrap (`chsh`,
which will ask for your password — that's normal, no root needed here).

## 2. Side projects — by folder, NOT in a heap
```
~/projects/
  coursework-anxiety/
  burnout-questionnaire/
  python-practice/
```
Rule: **each project gets its own folder**, don't dump everything together.
**Don't dedup.** If the same dataset/script is needed in two projects — let it
sit as a copy in both. Better two honest copies in clear places than one "smart"
link you forget about a month later. Cleanliness matters more than saving space —
space is cheap, your head is expensive.

## 3. Knowledge base — `~/kb/`
Flat markdown notes: what you learned, what you fixed, how you did it.
```
~/kb/
  linux-commands.md
  statistics-cheatsheets.md
  what-broke-and-how-i-fixed-it.md
```
Rules:
- **Append, don't rewrite.** New stuff at the bottom, with a date. Don't erase the
  old (the context might come in handy). Again — don't dedup.
- One note = one thought/case. A clear heading.
- This is your memory. Half a year from now you'll thank yourself.

## 4. "What is where" — the `where` command
A map of the laptop in one command: where the projects are, where the knowledge
base is, where the logs are, where the configs are, what commands exist. It lives
in `~/.config/kit-claude/layout.md`, edit it freely. Forgot where to put
something — type `where`.

## 5. Search — the `recall` command
One entry point into "what I know" and "what happened":
```
recall "how i fixed wifi"    # searches ~/kb (your notes) AND the system logs
recall --notes "anova"        # notes only
recall --logs "nvidia"        # system journal only (journalctl)
```
This way "log search" and "knowledge base" become one habit, not ten commands.

## 6. Output — through aliases, no memorizing by hand
The main handles: `where` (map), `recall` (search), `kit-help` (cheat sheet),
`update` (update + check), `fix` (repair). They're also shown when the terminal
starts (fastfetch), so you don't have to cram anything.

---

**The spirit of the method:** structure on the outside (folders, notes, a map),
so your head is free on the inside. Don't optimize prematurely, don't dedup, keep
traces (notes/logs) — your future self sees more than it seems right now.
