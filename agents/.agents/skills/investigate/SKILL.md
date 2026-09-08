---
name: investigate
description: Fan out oracles over a question, each leaving a durable index, and consolidate them into one map.
disable-model-invocation: true
---

Answer a question about a codebase with **oracles**: investigators that each explore one scope in isolation, leave a durable **index** behind, and report a path instead of their findings. You stay ignorant of the raw detail on purpose, because you have to survive into the design session that queries these oracles next.

Everything written here goes to scratch, keyed by repo and branch:

```bash
agent-scratch
```

That path is the one every agent must resolve for itself by running the same command. No vault, no repo, nothing to clean up out of git.

## 1. Cut the question into scopes

A **scope** is an area one agent can explore without needing another's answer. Two scopes are independent when neither one's findings change how you would search the other.

Cut the question, then count:

- **One scope**: investigate it yourself, here. Go to step 4 with your own index.
- **Several**: one oracle each.

Fan-out follows the cut, so let the cut decide it. Splitting a single scope across two agents to go faster buys you the same files read twice and the same claims written twice.

Scope names become agent names, so keep them to `[a-z][a-z0-9_-]{0,31}`.

## 2. Start the oracles

Confirm `HERDR_ENV=1` and read `herdr --skill` once for the current CLI.

One pane per oracle, split off your own, your focus left where it is:

```bash
herdr pane split --current --direction right --cwd "$PWD" --no-focus
herdr agent start <scope> --kind claude --pane <returned-pane-id>
```

Prompt every oracle first, then wait on them, so the fan-out stays concurrent:

```bash
herdr agent prompt <scope> "<the SOP below, plus this oracle's scope>"
herdr agent wait <scope> --timeout 900000
```

Give each oracle the SOP verbatim, its scope, and the entry points you already know. Every file you can name is context it spends on the question instead of on finding the door.

## 3. Collect paths

Each oracle answers with its index path and overview:

```bash
herdr agent read <scope> --source recent-unwrapped --lines 40
```

Agents that run on the terminal's alternate screen leave no scrollback, so when that read comes back empty, read the Overview section out of the index file. Keeping the overview in the file is what makes the reply disposable.

Read overviews. Leave the claims where they are: their bulk is the exhaust the fan-out existed to keep out of you, and step 5 is worth more to you than knowing the answer early.

## 4. Consolidate into a map

**One index** is already the map. Copy it to `map.md`.

**Several**: start one more agent, hand it only the index paths, and have it write `map.md` beside them. Its job is to reconcile the indices into one account: fold duplicate claims together, name the contradictions rather than picking a winner, carry every claim's evidence through, and collect what no index settled. It is a fresh context on purpose, so consolidation costs you nothing.

Then read `map.md`. It is the first raw detail you take on, and the last.

Done when `map.md` exists and every claim in it still has a file and line behind it.

## 5. Warm or exit

**Exit** by default: close the panes you opened, and tell the user where `map.md` is.

**Stay warm** only when a design session is starting now and will ask these oracles things the map cannot answer. Consolidation deletes nuance, and design lives in the nuance, so a warm oracle beats a good map at that one job. "It could be useful later" is not that condition; later, the map and the indices are still on disk.

Either way, say which panes you left open and which you closed. A pane the user does not know about is a pane they find tomorrow.

## The oracle SOP

Hand this to each oracle verbatim, then append its scope and its entry points.

> You are an oracle. You explore one scope of a codebase and leave behind an index that someone who has not read the code will rely on.
>
> Run `agent-scratch` to get your scratch directory. Write your index there as `index-<scope>.md`:
>
> ```markdown
> # <scope>
>
> ## Overview
> Three to five lines: what this area is, and the one thing that would most surprise
> someone who had not read it.
>
> ## Claims
> - A statement of fact about the code. `path/to/file.ts:412`
>
> ## Open
> - A question this scope could not settle, and what would settle it.
> ```
>
> A **claim** is a fact with a file and a line behind it: "the tenant join is unconditional, `UserRepo.ts:412`". Write what the code does, not what you infer it means. Anything you believe but cannot cite belongs under Open.
>
> Leave your reasoning out. The files you opened, the searches that missed, the theory you dropped: that is exhaust, and keeping it out of the next reader's head is the whole point of the index.
>
> Reply with the index path and its Overview, and nothing else.
>
> Then stay put. You may be asked follow-up questions about your scope.
