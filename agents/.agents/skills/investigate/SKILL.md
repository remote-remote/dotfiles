---
name: investigate
description: Fan out oracles over a question, conclude in the open, and leave the answer in a vault note.
disable-model-invocation: true
---

Answer a question about a codebase with **oracles**: investigators that each explore one scope in isolation, leave a durable **index** behind, and report a path instead of their findings. You stay ignorant of the raw detail on purpose, because you have to survive into the conversation that queries these oracles next.

Three kinds of statement come out of an investigation, and keeping them apart is what makes the note worth reading a month later:

- A **claim** is a fact with a file and a line behind it. Oracles write claims.
- A **conclusion** is what the claims add up to: "X is happening, because Y." It answers the question. An oracle usually reaches it first, or it falls out of consolidation once the scopes sit side by side.
- A **decision** is a choice made, and what it rules out.

Claims stay in scratch, where their bulk costs nobody anything. Conclusions and decisions go into a vault note that you write. An investigation that reaches a conclusion and decides nothing is a finished one, not a stalled one; most of them are.

Scratch is keyed by repo alone:

```bash
agent-scratch --repo
```

Branch-keyed scratch would orphan the evidence the moment `flow work` checks out an issue branch, which is the exact point the investigation succeeds. Resolve it once, here, and hand the path to every oracle. The note records it too, so it stays findable once this session is gone.

**Early exit.** A question that is only "how does this work" ends at the map: nothing to conclude, nothing decided, nothing worth keeping past today. Skip step 2, stop after step 5, and hand the user `map.md`. A conclusion on its own is enough to keep the note. If you only discover mid-way that there is neither a conclusion nor a decision, `rm` the note and exit the same way.

## 1. Cut the question into scopes

A **scope** is an area one agent can explore without needing another's answer. Two scopes are independent when neither one's findings change how you would search the other.

Cut the question, then count:

- **One scope**: investigate it yourself, here. Go to step 5 with your own index.
- **Several**: one oracle each.

Fan-out follows the cut, so let the cut decide it. Splitting a single scope across two agents to go faster buys you the same files read twice and the same claims written twice.

Scope names become agent names and filenames, so keep them to `[a-z][a-z0-9_-]{0,31}`.

## 2. Open the note

Two entry points. Use `project plan` when the investigation is into a project that already has a note in the vault, `investigate` otherwise:

```bash
flow investigate "<title>" --no-open --scratch "$scratch" --scope <a> --scope <b>
flow project plan "<name>" --no-open --scratch "$scratch" --scope <a> --scope <b>
```

Add `--task` when you know it, and `--project` on `investigate` when the work belongs to a project it is not scoped under. The note path is printed to stdout; hold onto it.

Write the question into `## Question` before you fan out. It is the one thing the oracles cannot reconstruct later, and every conclusion is measured against it.

## 3. Start the oracles

Confirm `HERDR_ENV=1` and read `herdr --skill` once for the current CLI.

One pane per oracle, split off your own, your focus left where it is:

```bash
herdr pane split --current --direction right --cwd "$PWD" --no-focus
herdr agent start <scope> --kind claude --pane <returned-pane-id>
```

Prompt every oracle before waiting on any of them. That is what makes the fan-out concurrent, and folding a wait in beside the prompt here turns it back into one oracle at a time:

```bash
herdr agent prompt <scope> "<the SOP below, plus this oracle's scope and scratch path>"
```

Give each oracle the SOP verbatim, its scope, the scratch path, and the entry points you already know. Every file you can name is context it spends on the question instead of on finding the door.

## 4. Collect answers

Take the oracles one at a time. Each answers with its index path, overview and conclusions:

```bash
herdr agent wait <scope> --timeout 900000
herdr agent read <scope> --source recent-unwrapped --lines 40
```

Waiting here rather than at the fan-out is what frees you between scopes: the first oracle's conclusions reach the user while the rest are still working. Consolidation needs every index, and every scope has been waited on by the time this step ends, so step 5 adds no barrier of its own.

Agents that run on the terminal's alternate screen leave no scrollback, so when that read comes back empty, read those sections out of the index file. Keeping them in the file is what makes the reply disposable.

Read the overviews and conclusions. Leave the claims where they are: their bulk is the exhaust the fan-out existed to keep out of you, and the oracles are still up if you need one.

**Talk early, conclude after the map.** One scope's account is confidently wrong in exactly the ways the cross-scope view exists to catch, and a half-collected fan-out reads as a finished one. Put what has landed in front of the user as it lands; the Log stays shut until step 6.

## 5. Consolidate into a map

**One index** is already the map. Copy it to `map.md`.

**Several**: start one more agent, hand it only the index paths, and have it write `map.md` beside them. Its job is to reconcile the indices into one account: fold duplicate claims together, name the contradictions rather than picking a winner, carry every claim's evidence through, and collect what no index settled. It carries each index's conclusions through under the claims that hold them up, and states any conclusion that only becomes visible with the scopes side by side, which is the one thing it can see and no oracle can. It is a fresh context on purpose, so consolidation costs you nothing.

Then read `map.md`. It is the first raw detail you take on.

## 6. Conclude in the open

The map is an account of the code. What it adds up to, and what the user decides to do about it, go into the note's `## Log` as they land.

**Answer the question first.** The conclusion is what most investigations produce, so write it before anything else: "X is happening, because Y", measured against `## Question`. Decisions may follow it or may not; zero is a normal count.

**Write without asking.** There is no approval step. The vault is private, a wrong entry costs one `rm`, and a confirmation prompt rebuilds the friction that made manual recording fail.

**Write granular.** The small conclusions and the small decisions are the ones gone by tomorrow. Length is free here: this note is input to distillation, not a document anyone reads front to back.

**Carry the evidence through.** Bring the `file:line` of the claims behind an entry into the entry, so it still stands up after the scratch directory is cleared.

**Supersede in place.** A dead end, or a conclusion a later claim overturns, stays in the Log with the reason it died written under it. Deleted, it takes with it the only record that the idea was had, and the next person to have it pays for it twice.

**Ask the oracle, not the map.** The oracles are still warm, and consolidation deletes the nuance that both conclusions and design live in:

```bash
herdr agent prompt <scope> "<the question>"
herdr agent wait <scope> --timeout 300000
```

## 7. Close down

Done when the Log answers the question, and holds whatever was decided about the answer.

Close the panes you opened, and say which ones you closed. A pane the user does not know about is a pane they find tomorrow.

**The note is the handoff**, so write no other document. It carries the question, the conclusions, the decisions, the scratch path and the scope names, which is everything the next session or the distillation skills need.

## Resuming

An investigation can span days, and its note is self-describing: frontmatter carries `scratch:` and `scopes:`.

Scope names are herdr agent names, so restart a scope by starting an agent under the same name and handing it the SOP, the scratch path, and the path to its own `index-<scope>.md`. Told to read its index first, it resumes from what it already knows rather than re-reading the code.

## The oracle SOP

Hand this to each oracle verbatim, then append its scope, its scratch path, and its entry points.

> You are an oracle. You explore one scope of a codebase and leave behind an index that someone who has not read the code will rely on.
>
> Write your index into the scratch directory you were given, as `index-<scope>.md`. If it is already there, read it first: you are resuming, and what it already claims does not need finding twice.
>
> ```markdown
> # <scope>
>
> ## Overview
> Three to five lines: what this area is, and the one thing that would most surprise
> someone who had not read it.
>
> ## Conclusions
> - What the claims below add up to, naming the ones that carry it.
>
> ## Claims
> - A statement of fact about the code. `path/to/file.ts:412`
>
> ## Open
> - A question this scope could not settle, and what would settle it.
> ```
>
> A **claim** is a fact with a file and a line behind it: "the tenant join is unconditional, `UserRepo.ts:412`". Keep inference out of it. Write what the code does, not what you take it to mean.
>
> Inference has its own section. A **conclusion** is what your claims add up to, "X is happening, because Y", and it holds only for as long as the claims named under it do. What you believe but cannot pin to claims is an Open, not a conclusion, and a scope that concludes nothing says so.
>
> Leave your reasoning out of all of it. The files you opened, the searches that missed, the theory you dropped: that is exhaust, and keeping it out of the next reader's head is the whole point of the index.
>
> Reply with the index path, your Overview and your Conclusions, and nothing else.
>
> Then stay put. Follow-up questions about your scope are coming, and they will want the nuance the index left out.
