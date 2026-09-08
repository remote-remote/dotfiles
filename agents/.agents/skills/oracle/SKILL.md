---
name: oracle
description: Evidence-backed investigation of a bounded codebase question. Use when assigned an oracle role or when another workflow requests an oracle index.
---

Investigate one scope and leave a durable **index** that someone who has not read the code can rely on. This skill defines the investigator's work, not agent startup, scratch allocation, or note capture. It works in the current conversation or in a delegated agent.

## Interface

Required inputs:

- **Question:** what to settle.
- **Scope:** the area to investigate and what is outside it.
- **Index path:** the absolute path where findings belong.

Optional inputs: known entry points and an explicit **resume** instruction. Resolve missing required inputs with the caller before investigating. An existing index is not permission to resume or overwrite it: ask the caller which it intends.

The index is the durable result. Reply with its path, a short overview, supported conclusions, and blockers. Agent lifetime belongs to the caller; follow-ups use and update the same index.

## 1. Establish the evidence baseline

Record the repository root, current commit (or that none exists), and worktree state, including relevant untracked files. Investigate the code as it exists, distinguishing committed code from local changes.

On explicit resume, read the existing index first. Compare its baseline with the current revision and worktree, then revalidate claims whose cited code or dependencies changed. A commit match alone does not validate dirty-worktree evidence. Treat stale or unverifiable claims as Open until checked; use the index to guide the search rather than as current truth.

Mark the index Status as in-progress for this attempt before investigating. Done when the question, scope, and baseline are recorded, and reused claims are either validated or marked stale.

## 2. Investigate

Trace the behavior relevant to the question through its callers, implementation, and tests within scope. Look for evidence that would disprove the emerging answer, including conditional paths and counterexamples. Request a scope expansion or name the missing external evidence when the answer depends on code outside scope.

Keep these distinct:

- A **claim** is an observed fact supported by evidence. State the conditions under which it holds. Code establishes what a path does, not that production necessarily executed it.
- A **conclusion** is what named claims support. An inference that lacks sufficient evidence belongs in Open, not Conclusions.
- A **rejected hypothesis** is a plausible explanation ruled out by evidence. Preserve the hypothesis and the disconfirming evidence, not the chronological search diary.

Cite code with repo-relative `file:line` and the recorded revision. For dirty or untracked evidence, include a small relevant excerpt or other durable snapshot in the index, labeled as local. For runtime observations, record the command or source, relevant environment, and observed result. Keep secrets out of artifacts.

Keep source and configuration unchanged. Run checks only within the caller's authorization; request approval for changes or side-effecting experiments. Write findings to the supplied index path.

Done when the question is answered within scope, or the index identifies the missing evidence and what would settle it. Exhausting an authorized budget or encountering a blocker is a valid inconclusive result, not grounds to strengthen a guess.

## 3. Write the index

Use stable scope-qualified claim IDs so conclusions and cross-scope synthesis can reference evidence without ambiguity. Preserve IDs when updating; mark invalidated claims instead of silently assigning their IDs to different facts.

```markdown
# <scope>

## Question and scope
<question, scope, exclusions>

## Baseline
<repo root, revision, worktree state, verification date>

## Overview
<what this area does and the most relevant finding, in three to five lines>

## Conclusions
- <conclusion supported by scope:C1 and scope:C2, with limits>

## Claims
- scope:C1: <observed fact and conditions>. `path/to/file.ts:412` at <revision>

## Rejected hypotheses
- <hypothesis>: ruled out by <claim IDs>.

## Open
- <unresolved question or stale claim>; settle with <specific evidence or action>.

## Status
<answered | inconclusive>, with the reason for any remaining gap
```

Keep the required sections shown above; omit Rejected hypotheses when empty. Say explicitly when there are no supported conclusions or no open questions. Before publishing a terminal status, check that the baseline still matches the evidence, revalidating affected claims if code changed during investigation. Verify every conclusion's supporting claims and every claim's evidence before replying.

## Follow-ups

Read the index and check for baseline changes before answering. Investigate the follow-up under the same evidence rules and update the index before replying. Preserve superseded conclusions with the evidence that overturned them. Recommendations remain recommendations; the oracle does not make decisions for the caller.
