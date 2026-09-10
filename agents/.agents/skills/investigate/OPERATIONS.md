# Investigation workspace, record, and orchestration

Reference for framing and the investigation partner. These mechanics support the conversation; they do not authorize further investigation.

## Workspace and working record

Confirm `agent-scratch` is available before allocation. The repo-stable root collects every investigation into a repository, so list what is already there before starting another one:

```bash
root="$(agent-scratch --repo)" || exit
find "$root" -maxdepth 1 -type d -name 'investigate-*' | while read -r run; do
	printf '\n%s\n' "$run"
	grep -E '^- (state|working record):' "$run/run.md" 2>/dev/null ||
		echo "  no run.md: interrupted framing"
done
```

Report every run that is not `completed` or `cancelled`, and ask whether the user wants to resume one before allocating. A listed run is a reason to ask, never permission to resume or overwrite; a resume uses the exact directory the user confirms. Allocate only once the user wants a new investigation:

```bash
scratch="$(mktemp -d "$root/investigate-XXXXXXXX")" || exit
```

Repo-stable scratch is shared across worktrees. For cross-repository investigations, choose an anchor repository and record every repository's absolute root separately. `agent-scratch` requires a Git repository in both modes. If no repository is established yet, ask the user to select an anchor or an explicit scratch location; retain that absolute path when repositories are identified. Matching names, titles, or scope aliases establish nothing about which run is which.

Keep these files in the unique directory:

- `brief.md`: agreed starting point and current direction, with continuation pointers.
- `run.md`: operational manifest: state (`framing`, `active`, `paused`, `completed`, `cancelled`, or `blocked`), anchor and repository roots, working-record path and mode, distilled artifact paths when any, and oracle bindings.
- `index-<scope>.md`: investigation-owned oracle indices. Borrowed oracles retain their existing index paths.
- `map.md`: working record only when using scratch output.

Use `[a-z][a-z0-9_-]{0,31}` for local scope aliases used in filenames. An alias is unique only within one investigation, which is why indices belong in the run directory and never in the repo-stable root beside it. For each oracle, record repository root, coverage and exclusions, entry points, absolute index path, claim namespace, execution method, ownership (`owned` or `borrowed`), verified agent identity and pane ID if applicable, and current request ID/status. Scope aliases are not globally unique agent identities or evidence namespaces.

**Vault output is the default working record.** Explicit scratch-only (also called map-only) output uses `map.md` with the same logging discipline. This choice is where working memory lives, not the form of the eventual distilled artifact. Missing required tools are a blocker to resolve with the user, not permission to silently change output mode. Artifact paths are reported to the user so the investigation can be resumed.

### Vault notes

Confirm `flow` is available. Open the working note during framing, before the handoff. Use `project plan` for an existing project and `investigate` otherwise:

```bash
flow investigate "<title>" --no-open --scratch "$scratch"
flow project plan "<name>" --no-open --scratch "$scratch"
```

Add repeated `--scope <alias>` flags for scopes already known; framing need not invent scopes. Add `--task` when known, and `--project` on `investigate` when applicable. Confirm stdout is an absolute path to an existing file: an unconfigured tool can exit 0 with an explanatory message. Record the validated path in `run.md`.

Use `## Question` for the starting problem or goal even when it is not a single question; use `## Log` for the working entries. Link the brief and scratch directory. Verify the note's frontmatter points to this run and its current scopes. Scaffolding an existing note is a no-op, so update stale metadata when scopes or runs change. Preserve existing content and explicit links from every earlier run to its brief and scratch evidence rather than replacing the only route back to them.

On resume, open the recorded note rather than scaffolding another. If switching from scratch to vault, create or resolve the note, transfer the existing record, and update the manifest to name the authoritative working record. Preserve the old path as a pointer rather than maintaining two diverging logs.

## Recording rules

During both framing and exploration, use the working record as shared memory, not a transcript. Maintain a short current understanding and visible open questions, with granular entries in `## Log`:

- **Finding:** an evidenced observation or supported conclusion, with conditions and provenance. Distinguish code evidence, runtime observations, and user reports; code alone does not establish what executed in production.
- **Idea:** a hypothesis, possible change, or recommendation still being considered, including what would test it.
- **Decision:** a choice the user actually made, why, and alternatives or implications it rules out.
- **Open:** an unresolved question, constraint, or evidence gap and what could settle it.

Record automatically as these land; recording does not authorize deciding. Preserve distinct small decisions rather than collapsing them into a broad summary. Mark superseded entries and link their replacements; preserve rejected ideas with the reasoning or evidence that ruled them out. Omit routine search diaries and conversational filler.

Carry revision-aware citations, source-index links, and necessary local excerpts into substantive findings so they survive scratch cleanup. Retain originating repository and claim IDs when using peer evidence. Link to indices for depth, not as the sole support for a conclusion. Keep secrets out of every artifact.

## Oracle execution

Local operation is available without another agent: follow the oracle skill for the current orientation or question, updating its index. Explain when running locally instead of providing a warm delegated oracle.

Use Herdr only when the user explicitly authorizes Herdr orchestration and `HERDR_ENV=1`. Read the [Herdr skill](../herdr/SKILL.md) and its release-matched instructions before operating it. Otherwise offer local operation or resolve delegation with the user; do not invent an agent transport.

Give each oracle:

- The absolute oracle skill path and an instruction to read and follow it.
- Repository root(s), bounded coverage and exclusions, known entry points, and overall context.
- An absolute index path and unique claim namespace for a new index, or an explicit resume instruction for a known existing index.
- A request ID, mode (`orient` or `question`), the immediate request, and its stopping point.
- Known peer identities, coverage, and consultation authorization, when applicable.

For delegated startup, use available names within CLI constraints, namespaced to the investigation. Record ownership and verified identity as each agent or pane is created, keeping the user's focus. Never reuse an agent just because its name matches a scope. Borrowing a persistent oracle requires an explicitly identified, authorized agent; retain its index and record it as borrowed. Serialize requests to an oracle rather than having competing requests overwrite its current status or index.

Keep successful oracles available across conversational turns. Peer consultation uses known authorized agents only; requests do not authorize recursive agent creation. The partner is the sole writer of the investigation record; each oracle owns its index.

### Collecting a request

Read the oracle's response and relevant index sections, not an exhaustive merged evidence dump. A wait ending is not proof of completion: verify the index identity and the requested ID, mode, and outcome in Status or completed Requests. Request IDs must be unique across users of a borrowed oracle, for example `<run-id>:<sequence>`. Orientation returns `ready`, `partial`, or `blocked`; a question returns `answered`, `inconclusive`, or `blocked`. These describe the request, not completion of the whole investigation.

On empty or truncated output, inspect the index. On a timeout, failed agent, or malformed result, make at most one completion retry, then report the blocker and partial evidence. Check existing work before retrying so a timeout does not start duplicate work. Never present an earlier request's terminal status as a fresh result.

## Resume and lifecycle

Read the exact brief, manifest, and working record. Missing scratch or indices are evidence gaps to reconstruct, not grounds to trust summaries as current facts. Ask for a new workspace location if the recorded one is unavailable. Preserve surviving artifacts and their provenance.

Verify live oracle identities and repository coverage before reusing them. Request baseline validation for relevant evidence under the oracle skill, including dirty-worktree and cross-repository changes. A missing agent can be replaced with a new identity using the same durable index and an explicit resume instruction; update its binding. Oracle knowledge is not tied to a pane's lifetime.

Framing handoff and ordinary conversational turns leave the workspace intact. On explicit pause, completion, cancellation, or failure after partial startup, close only investigation-owned agents and panes, unless the user asks to retain them. Borrowed persistent oracles remain alive. Record outstanding requests when pausing; stop owned work through the supported transport and avoid interrupting unrelated work in a borrowed oracle.

Before closing anything, verify current ownership against recorded IDs. Stale IDs after an interruption are not sufficient proof. Report retained agents, unverifiable ownership, or cleanup failures rather than claiming cleanup succeeded. Preserve substantive and pre-existing notes; remove only a newly created empty scaffold when the user requests removal.
