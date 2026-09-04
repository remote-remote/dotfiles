---
name: herdr
description: "Control Herdr, a terminal multiplexer for coding agents. Use only when the user explicitly mentions Herdr or asks to use Herdr to inspect or control panes, tabs, workspaces, commands, or another agent. Do not use merely because a task could benefit from a background terminal, delegation, or parallel work. Requires HERDR_ENV=1."
---

# Herdr

The real instructions ship inside the installed binary, not in this file, so they can
never drift from the version running on this machine.

First verify this agent is in a Herdr-managed pane. If this fails, say you are not
running inside Herdr and stop:

```bash
test "${HERDR_ENV:-}" = 1
```

Then print the release-matched skill and follow it as if it were written here:

```bash
herdr --skill
```

Run that once per session. If its output already appears earlier in this conversation,
work from that copy rather than printing it again.

It covers pane IDs, `pane split`, `pane run`, `pane read`, `pane wait-output`,
`agent start`, `agent prompt`, `agent wait`, and the focus and safety rules. Work from
that output rather than from memory of a previous session: the installed CLI is the
authority on command syntax.
