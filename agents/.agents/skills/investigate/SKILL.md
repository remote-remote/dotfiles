---
name: investigate
description: Frame an investigation together, explore with code oracles, and distill the findings and decisions into a useful artifact.
disable-model-invocation: true
---

Build shared understanding of a system, explore possible changes with the user, and preserve what emerges. Start from a symptom, goal, question, or area of uncertainty: debugging, project planning, migrations, and unfamiliar-code discovery use the same workflow.

This entry point owns **framing**. A fresh investigation partner owns the subsequent conversation; **oracles** provide grounded code knowledge. The handoff is an agreed **brief**, not an assignment to solve the whole problem autonomously. Keep source and configuration unchanged; side-effecting experiments require explicit authorization.

## 1. Orient and sharpen the brief

Ask what prompted the investigation and help the user make it concrete. Read enough relevant code and project documentation locally to ask informed questions: locate likely entry points, understand terminology, and identify which systems participate. Stop orientation when you can explain that initial map and ask the next useful question. Leave causal tracing and broad oracle startup for the partner.

Work conversationally, one useful question or small related set at a time. Use what the user already supplied rather than making them fill out a questionnaire. For symptoms, seek a concrete example and expected versus observed behavior. For proposed work, clarify the desired outcome and existing constraints. Either may still be ambiguous when framing ends.

Read [OPERATIONS.md](OPERATIONS.md) when allocating scratch or opening the working record. Keep `$scratch/brief.md` current as material context lands:

- **Starting point:** the original symptom, goal, or uncertainty and why it matters.
- **Concrete context:** examples, user-provided observations, relevant repositories and entry points. Distinguish reported behavior from verified code facts.
- **Direction:** what we want to understand or decide first, constraints, exclusions, and any explicit authorization for orchestration or experiments.
- **Unknowns and ideas:** unanswered questions and tentative hypotheses, not assumed premises.
- **Agreements:** decisions already made and their rationale, or links to entries in the working record.
- **Continuation:** absolute paths to the working record, `run.md`, and `PARTNER.md`; the first topic to discuss next.

Use code citations for verified observations. Reference existing artifacts rather than copying them wholesale. Capture substantive findings and decisions in the working record as they arise; the brief summarizes the agreed starting point, not the entire search history.

Show the brief's substance to the user and refine it with them. **Done when the user agrees it is useful enough to begin.** Open questions are expected; readiness does not require a fixed scope, a complete explanation, an oracle roster, or a chosen final artifact.

## 2. Hand off

Save the agreed brief before changing sessions. The default is a fresh context so the partner starts from deliberate framing rather than exploratory conversation residue.

Prepare a continuation prompt with resolved absolute paths:

> Read `<absolute PARTNER.md path>` and `<absolute brief.md path>`. Act as my interactive investigation partner. Start from the brief, establish the code context we need, and bring the first useful proposal or question back to me.

A skill cannot itself reset context. Use a supported session-handoff mechanism only when available and authorized; otherwise return the brief path and continuation prompt for the user to open in a new session. Do not claim a reset occurred or imitate one by ignoring earlier messages. If the user prefers to continue here, read [PARTNER.md](PARTNER.md) and explicitly continue without a reset.

This phase ends at the handoff. Preserve the working record and remaining uncertainties. On a later invocation with an existing investigation, read its brief and manifest, establish whether the user wants to reframe or resume the partner conversation, and reuse the recorded paths rather than allocating another run.
