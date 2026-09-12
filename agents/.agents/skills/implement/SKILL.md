---
name: implement
description: Take an unblocked vault task from agreed plan to committed, in slices the user reviews.
disable-model-invocation: true
---

Spend a plan that already exists. [`investigate`](../investigate/SKILL.md) builds understanding and writes the task note; this skill turns one such note into committed code, carved into **slices** the user reviews one at a time.

The user owns direction and judgement: no slice is committed without their approval, and feedback on a slice outranks the agreed plan. Invoking this skill is the standing authorization to commit at an approved slice boundary, and nowhere else. Every review gate is a safe stopping point, because the task's log and the working tree are current before you hand control back.

## 1. Pick a task

Resolve the vault and list what is open:

```bash
vault="$(sed -n 's/^vault_path: *//p' ~/.config/flow.yaml)"
grep -rl '^status: \(todo\|draft\)' "$vault/Projects"/*/Tasks/
```

If the user named a project or task, scope to it. Otherwise read the candidates' `## Notes` and `## Open`, plus their project note, and judge each **blocked** or not against three tests:

- **Open questions.** An unresolved `## Open` item that decides the shape of the change blocks the task; one that only records a limitation does not.
- **Predecessors.** A task naming an earlier slice, or wikilinking another task it builds on, waits for that one to reach `status: done`.
- **Ground truth.** The note's claims still hold in the current tree. A plan written against code that has since moved is a reframing job, not an implementation job.

Propose one task with the reason it is next, and name each blocked candidate in a line with what blocks it. **Done when the user confirms the task.**

Before any work starts, ask whether commits should carry your attribution trailers. Apply that answer to every commit for the rest of the session without asking again.

## 2. Plan the change

Read the task note whole, then the code it touches. Verify the note against the tree: cited paths, line references, and named functions either still exist or the difference is part of what you report.

Carve the work into slices. A slice is one coherent change that leaves the tree green and can be reviewed in a sitting. Prefer a seam the user could reject wholesale over a boundary that only makes sense mid-edit.

Where the note leaves a shape-deciding question open, or the code contradicts it, bring it back rather than choosing silently. When the task needs real exploration before it can be planned, say so and offer `/investigate`; this skill implements an existing plan rather than growing one.

Share the planned changes: the files touched and what changes in each, the slice boundaries and their order, the verification each slice ends on, and anything the note got wrong. Prose and file paths, not a diff. **Done when the user approves the plan, amendments included.**

If the approved plan drifts from the description in the ticket, add entries to the Task note briefly summarizing the decisions.

## 3. Work a slice

Implement the current slice only. Adjacent problems you notice go into the review note as observations, and into the plan only if the user puts them there.

Verify with what the project actually runs — its tests, typecheck, build — and report the real result, failures included.

Stop at the boundary and hand it over: what changed, the verification output, anything you would flag to a reviewer. **Done when the tree is green and the review request is with the user.** Waiting is the work here; the next slice starts after approval, not after your own satisfaction with this one.

## 4. Review, commit, continue

If you receive any change requests, add a brief entry to the `# Log` section of the Task note. Apply the user's feedback to the slice and return it for review again. Repeated feedback on the same seam is a signal the plan is wrong: bring the plan back rather than patching around it.

On approval, commit that slice alone, honoring the credit choice from step 1.

Then start the next slice at step 3.

## 5. Close the task

When every slice is committed, set `status: done` in the note's frontmatter and write a closing log entry: what now exists, and what stayed open. Work you discovered but did not do goes back to the user as a proposal, not a task note you create on your own.

Report the task note path, the commits, and anything left open. **Done when the note's status reflects the tree.**
