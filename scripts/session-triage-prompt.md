# session-triage: extraction prompt

Stage 1 is `session-triage list` (deterministic, free). This is stage 2 — hand a
shortlist slice to an agent. Split the shortlist into 2–4 groups by repo/area and run
one agent per group; do not point one agent at everything.

Two modes. Pick one per run — they want different things and mixing them dilutes both.

- **LOOSE ENDS** — a codebase you know. Payload is unfinished work.
- **SYSTEM KNOWLEDGE** — a codebase you don't. Payload is what the sessions prove about
  how the thing actually behaves. Use this at work.

---

You are doing an archaeology pass over ABANDONED coding-agent sessions. Output is a
TRIAGE list a tired human will skim — most entries should end up killed, and "nothing
here, kill it" is a valuable, correct answer. Do not pad.

INPUT: <path to shortlist slice>
Tab-separated: tool, user_turns, age_days, debug_keyword_hits, filepath.

CRITICAL — do not read these files whole, some are megabytes. Use `session-triage read
<file>` to print only the human/assistant prose; it drops tool calls and results, which
are the bulk. Pipe to a temp file, read the FIRST ~60 lines (what the session was for)
and the LAST ~80 (where it stopped and why). Sample the middle only if the ends are
ambiguous.

For each session determine:
1. What was worked on — one line, concrete, name the feature/bug/file.
2. Type: debugging | feature | refactor | chore | Q&A.
3. **What was ruled out / learned about the system.** HIGHEST-VALUE FIELD. Hypotheses
   tested and rejected, surprising facts about the codebase, dead ends proven dead.
   Prefer measured findings over described ones. "none" is allowed.
4. Where it stopped. Was the last assistant message an unanswered question or an
   untested proposal? Quote it if short.
5. Did it LAND? Get the session's cwd and last timestamp, then check git log in that
   repo after that date. landed | partial | no trace | unclear, with evidence.

OUTPUT — write to <out path>, max 6 lines per session:

### <short name> — <repo>, <age>d, <turns> turns
- **Was:** …
- **Type:** …
- **Learned/ruled out:** …
- **Stopped at:** …
- **Landed:** … — <evidence>
- **Verdict:** RESURRECT | REVIEW | KILL — <under 12 words>

KILL freely. A chore that completed, or a session with no durable residue, is a KILL even
if it ended mid-sentence. RESURRECT only for real unrecovered value. RESURRECT first,
KILL last.

Reply with ONLY the output path and a one-line tally. Do not paste the content back.

---

## In SYSTEM KNOWLEDGE mode, replace steps 3–5 with:

3. **What this proves about the system.** Only claims backed by something observed in the
   session — a test run, a stack trace, a measured value, a file actually read. Mark
   anything inferred as inferred.
4. **Traps.** Where the code's structure misled the agent or the human: a name that means
   something else, a layer that looks load-bearing and is a pass-through, a config that is
   read from somewhere unexpected, two things sharing a word.
5. **Still-open questions** about the system that the session raised and never settled.

Verdict becomes: HARVEST (goes in the traps doc / CLAUDE.md) | CONTEXT (useful background,
file it) | KILL.

## Afterwards

Verify every RESURRECT/HARVEST claim yourself before acting — check the file, run the git
command. Agents confabulate specifics, and a wrong claim in a document reads as more
authoritative than a wrong claim in a transcript. See [[2026-08-25-debugger-implementer-split]].
