# LAYOUT — a clean filesystem and memory (for you and for Claude)

This is the **structure** the method rests on. Pair it with
[`CONVENTIONS.md`](../CONVENTIONS.md): that file is *habits* (how you work — fish,
notes, `where`/`recall`); this one is *where files live*, kept clean **for you and
for Claude alike**.

> **Divide and conquer.** Every piece of context is its own module: one file, one
> concern, a clear title, loadable on its own. Then Claude pulls only what the task
> needs right now instead of dumping the whole disk into its head. The idea comes
> from the [agent-atlas](https://github.com/zzallirog/agent-atlas) layout; here it
> is folded down to a single machine.

## Why (one paragraph)
When everything is in one pile, Claude (like you) either **drowns** — reads the
whole home before any step — or **drifts** — loads too little and loses the main
task three turns ago. The fix isn't a bigger model, it's an arrangement: it is
decided in advance *what should be in front of you now, and what just sits on
disk*. That is the layout.

```
   +------------------------------------------------+
   |  PILE   whole home -> into context             |
   +------------------------------------------------+
        |
        |  drowns (too much)  /  drifts (too little)
        v
   +------------------------------------------------+
   |  LAYOUT   navigator -> only the module needed  |
   +------------------------------------------------+

   context stays small because it is chosen — not everything, always.
```

## 1. Navigator — a map, not a dump
At the root: **`~/CLAUDE.md`** — not a dump of everything, a **map**. It holds:
- **framing line** — one sentence: what this machine is and who you are;
- **30-second TL;DR** — 3–5 bullets: what you do, where things live, on what;
- **home map** — a tree of the folders that matter, one comment each;
- **invariants** — rules that must not break (marked as locked);
- **fast paths** — a table of routes (see §2);
- **what lives outside** — what is *not* here and where it is.

Each side-project gets its own small navigator `~/projects/<project>/AGENTS.md`
(the same map, about the project). Claude reads the navigator **first** and follows
it, instead of listing every file.

## 2. Fast paths — a route instead of reading everything
Inside the navigator, a table "to do X, read A then B":
```
### "add a new questionnaire"
1. -> projects/survey-X/AGENTS.md   (project map)
2. -> ~/kb/stats-cheatsheet.md       (which method)

### "why did the import fail"
1. recall --logs "import"            (what the journal says)
2. -> projects/.../clean.py          (entry point)
```
Rule: write a fast path **the second time** you hunt for the same route. The first
hunt is unavoidable; the second is a missing fast path.

## 3. Typed memory — `~/memory/`
Durable notes about the **work** (not the code) — the things Claude would otherwise
re-learn every session. Four types, small files, behind one index:

| Type | Holds | Answers |
|------|-------|---------|
| **profile** | who you are — role, how you learn, preferences | "how do I talk to you?" |
| **feedback** | how to work — corrections, and what landed | "have I been told how to do this?" |
| **project** | what's happening — goals, decisions, in-flight | "why this, and by when?" |
| **reference** | where things are — external systems, links, trackers | "where do I look that up?" |

Format — a short header (`name` / `description` / `type`) + body; for feedback and
project entries, lead with the **rule**, then a "Why:" and a "How to apply:" line.
One file = one thought (if it needs "and also", it's two files). All behind
**`~/memory/INDEX.md`** (one line per entry). The index is cheap to load whole;
entries load only when their index line says they're relevant.

> **Memory decays.** An entry is a point-in-time snapshot, not live state. Before
> acting on one that names a file/flag/version, verify it against how things are
> now. Wrong → **fix or delete it**, don't leave it. Memory nobody prunes is memory
> nobody can trust.

This is not a duplicate of `~/kb`: **`~/kb`** is your freeform notes (what you
learned, what you fixed — appended with a date, human-readable); **`~/memory`** is
typed, durable memory Claude loads selectively. Notes for the human, memory for
Claude.

## 4. Zones — shared, owned by no single project
Cross-cutting reference that belongs to no one project ("how stats work in R", "my
data-cleaning pipeline") lives in `~/kb/` by topic, one file per topic. The
navigator **points at** them, never copies them in.

## 5. On-demand + compaction — load only what's needed
- Context is small because it is **chosen**: navigator → the module you need →
  memory for the task. Not auto-injected, not "the whole home at once". The way in
  is `recall`.
- Moved to another project? Preload **its** navigator and the zones it cites — only
  those.
- Long session? Compaction may evict cold modules; as long as the main task lives
  in the **navigator** (not only in the chat), it stays re-derivable.

## 6. What "clean for Claude" means
- **Map, not dump** — the navigator routes, it doesn't hold a copy of everything.
- **Types and an index** — Claude loads an entry only when the index line is relevant.
- **Modularity** — one file = one concern → selective load, not all-or-nothing.
- **Freshness** — stale entries are fixed or deleted, or Claude acts confidently on a falsehood.

---
**Spirit:** structure on the outside so the inside — yours and Claude's — stays
free. The bootstrap lays the skeleton down (the "layout" step); it grows one module
at a time, each when it has earned its place.

---
🤝 **Handshake** — trust the trace, not the claim. The kit is pinned to one commit;
run `git rev-parse HEAD` and it must match the commit GitHub shows for the repo. (You
can't fake a commit hash from inside the commit — the same trick the whole kit runs on.)
