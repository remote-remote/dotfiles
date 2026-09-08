---
name: investigate
description: Coordinate scoped codebase investigations, conclude in the open, and capture the answer in a vault note or a scratch map.
disable-model-invocation: true
---

Answer a codebase question with **oracles**: investigators that each explore one scope and leave a durable index. The [oracle skill](../oracle/SKILL.md) owns investigation, evidence standards, the index format, and revalidation. Read it when investigating locally; pass its absolute path to delegated investigators so they read it themselves.

This skill owns scopes, orchestration, synthesis, and capture. **Claims** are evidenced observations; **conclusions** are what they support; **decisions** are choices the user has made and what those choices rule out. Keep those categories separate. A conclusion without a decision is a finished investigation.

## 1. Set up the investigation

Capture the question and choose the output:

- **Vault note** is the default, including for explanatory questions. It holds conclusions, open questions, and any decisions.
- **Map-only** is an explicit lightweight output choice. Keep the answer in scratch and return `map.md`; note capture can be added later without repeating the investigation.

A scope is an area one investigator can explore without another investigator's answer changing how it should search. Cut the question into independent scopes; use one oracle per scope. Keep dependent work sequential rather than forcing a fan-out. Scope names become filenames, so use `[a-z][a-z0-9_-]{0,31}`.

**Preflight before creating a note.** Confirm `agent-scratch` is available, and `flow` for vault output. One scope runs locally. For several scopes, use Herdr only when the user has authorized that orchestration and `HERDR_ENV=1`; read the [Herdr skill](../herdr/SKILL.md) and its release-matched instructions before operating it. Otherwise report the limitation and investigate locally, one scope at a time. A missing required tool is a blocker to resolve with the user, not a reason to silently change the requested output.

For a **new** investigation, allocate a unique directory under repo-stable scratch:

```bash
root="$(agent-scratch --repo)" || exit
scratch="$(mktemp -d "$root/investigate-XXXXXXXX")" || exit
```

Repo-stable scratch is shared by every worktree of the repo, so it survives both a branch switch and the worktree the investigation started in; the unique child keeps separate investigations from overwriting one another. For a **resume**, use the exact recorded investigation directory instead. Never infer resume from a matching scope name or an existing index.

Create or update `$scratch/run.md` with the question, output mode, note path if any, and a scope table: subquestion, exclusions, entry points, index path, and status. Record owned agent names and pane IDs as they are created. This is the scratch manifest, not a second user-facing handoff. Keep the indices and `map.md` in this directory.

Done when every scope has a bounded subquestion and an index path, and the output mode and execution method are known.

## 2. Open the note

For vault output, open the note before investigating, including the one-scope branch. Use `project plan` for an investigation into an existing project, and `investigate` otherwise:

```bash
flow investigate "<title>" --no-open --scratch "$scratch" --scope <a> --scope <b>
flow project plan "<name>" --no-open --scratch "$scratch" --scope <a> --scope <b>
```

Pass only the scopes in this run. Add `--task` when known, and `--project` on `investigate` when it belongs to a project. Confirm the path printed to stdout is an absolute path to a file that exists, since these commands exit 0 and print an explanatory message instead when the tool is unconfigured; record it in the manifest. Preserve existing note content and links to earlier investigations when a command resolves to an existing note. On resume, open the recorded note rather than scaffolding another.

Write the question into `## Question`, and verify the frontmatter records this run's scratch path and scope names. Scaffolding over an existing note is a no-op that silently keeps the first run's frontmatter, so a second run into the same note, or a scope added mid-run, needs the frontmatter corrected by editing the note. That link is the only route back to the evidence. If this note covers several runs, preserve each run's question and scratch link rather than replacing the only reference to earlier evidence.

For map-only output, the manifest holds the question; skip note creation, not the remaining workflow.

## 3. Investigate each scope

Give each oracle:

- The absolute path to the oracle skill, with an instruction to read and follow it.
- The overall question and its bounded subquestion.
- Its scope and exclusions, plus known entry points.
- Its absolute index path, `$scratch/index-<scope>.md`.
- An explicit resume instruction only when reusing that investigation's index.

**Local:** follow the oracle skill for each scope, write its index, then proceed to collection. No agent or pane is needed for the one-scope case.

**Delegated:** use the installed Herdr instructions to split one pane per oracle from your own pane, keep your focus, and start an agent in the repository. Choose available agent names within the CLI's constraints, namespaced to this investigation; record their mapping to scopes and pane IDs. Scope names alone are not globally unique agent identities. Never reuse or close an unrelated agent based on its name.

Prompt every independent oracle before waiting on any. Keep successful oracles available for follow-ups until cleanup.

## 4. Collect results

Read each oracle's reply and its index's Overview, Conclusions, Open, and Status sections. Surface results as they become available, labeled as provisional scope findings until synthesis. Keep exhaustive claims out of the coordinator's context unless needed to resolve a particular issue.

A wait ending is not proof of a completed index. Check the artifact exists, belongs to this question, and has a terminal status produced by the current attempt; a previous attempt's completed index is not a fresh result. If terminal output is empty or truncated, read the relevant sections from the index. On a timeout, failed agent, or malformed index, request completion or report the scope as blocked; use a bounded retry rather than waiting indefinitely. Partial evidence must remain labeled partial.

Done when every scope is either answered, inconclusive, or blocked, with the reason recorded in the manifest. Continue with partial coverage when useful, but carry the gaps into the answer.

## 5. Synthesize a map

Write `$scratch/map.md` as an answer-oriented summary, not a merged dump of every claim. One scope needs no additional agent; summarize its index locally. For several delegated scopes, start a fresh consolidator using the same ownership bookkeeping. Give it the overall question, all index paths, scope statuses including missing or failed scopes, and the absolute oracle skill path to read for evidence standards (not its index-writing workflow). It writes the map and returns its path. When delegation is unavailable, synthesize locally.

The map contains:

- **Answer and status:** answered or inconclusive, with the supported answer and its limits.
- **Supporting evidence:** only the claims needed for that answer, preserving claim IDs, revision-aware citations, and source-index links.
- **Cross-scope findings:** duplicate claims reconciled, new conclusions tied to their supporting claims, and contradictions named rather than silently resolved.
- **Rejected hypotheses:** those relevant to the question, with disconfirming evidence.
- **Open:** unresolved questions, blocked scopes, and what would settle each.
- **Indices:** links to the exhaustive evidence.

Keep the map to roughly 150 lines or less; leave supporting detail in the indices rather than dropping qualifications to meet the target. The consolidator applies the oracle evidence standards and makes synthesis explicit rather than presenting inference as observation.

Read the map. Check that it addresses the question, supports its conclusions, and accounts for all scopes. Treat mismatched evidence baselines as a gap, not a coherent snapshot. For material contradictions or missing support, ask the relevant oracle to investigate and update its index, then refresh the map. Do not choose a winner by confidence alone. Stop with an inconclusive answer when the necessary evidence is unavailable or the authorized budget is exhausted.

## 6. Conclude in the open

Present the supported answer first, including limits and unresolved blockers. For vault output, write entries into `## Log` as conclusions and decisions land; map-only output keeps them in the map, clearly distinguished from code evidence. If the user switches to vault output, perform step 2 and capture the existing findings.

- **Record without a confirmation prompt.** Capture conclusions and decisions already made; automatic recording does not authorize making decisions. Label proposed actions as recommendations until the user adopts them.
- **Write granular entries.** Preserve distinct conclusions and small decisions, each with its supporting evidence or rationale.
- **Carry evidence into the note.** Include the revision-aware citations and necessary local excerpts behind an entry so it survives scratch cleanup. Link to scratch for depth, not as the sole support for the answer.
- **Supersede in place.** Preserve overturned conclusions and rejected hypotheses with the evidence that ruled them out. Omit search diaries.
- **Keep open questions visible.** Record what is known, what remains unresolved, and what evidence or action would settle it. No supported conclusion is a valid result.

Follow-ups go to the relevant oracle, using the recorded agent mapping or running the oracle skill locally if that agent is gone. Have it update its index, then refresh the map and affected note entries. Resuming evidence follows the oracle's baseline-validation rules.

## 7. Finish and clean up

An investigation is complete when every scope has a recorded outcome and the selected artifact contains either a supported answer or an explicit inconclusive result, plus any decisions actually made. The user may also pause or cancel it; record that state and remaining work.

**Every exit runs cleanup:** vault output, map-only output, an inconclusive result, cancellation, or failure after partial startup. Close only the agents and panes this run opened, including the consolidator, using recorded IDs and verified ownership. If the user asks to keep them alive, record and report what remains. On resume after an interruption, verify stale IDs before acting; never close a pane whose ownership cannot be established.

Return the note path, or `map.md` for map-only output, the completion status, and which panes were closed or remain open. Report cleanup failures rather than claiming success. Keep notes with inconclusive findings; remove a note only if it is a newly created scaffold with no substantive entries and the user requested removal. Preserve existing notes.

The selected artifact is the user-facing handoff; the scratch manifest and indices are its supporting material. Write no additional handoff document.

## Resuming

Start from the note's recorded scratch link or the map-only run's manifest. Read `run.md`, retain the original question and index paths, and inspect any live owned agents before starting replacements. Missing scratch evidence is a gap to reconstruct, not permission to trust an old summary as current fact.

Give resumed oracles the same inputs as step 3 plus an explicit resume instruction. They validate the code baseline before reusing claims. Recollect affected scopes, refresh the map, and supersede changed note entries. Reuse a live owned agent or allocate a new available name and update the manifest; scope identity does not depend on agent lifetime.
