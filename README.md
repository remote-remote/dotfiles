# dotfiles

macOS setup managed by a mix of [Nix + home-manager](https://nix-community.github.io/home-manager/) and [GNU Stow](https://www.gnu.org/software/stow/).

## Initial Install

Clone this repo to `~/dotfiles`, then run:

```sh
~/dotfiles/scripts/install.sh
```

The script installs Xcode CLT, Homebrew + the Brewfile, Nix, stows the config packages below, runs home-manager, installs node/go globals, Claude Code, pi and (on a tmux machine) workmux, then tpm + tmux plugins, herdr plugins and the herdr agent integrations. It's idempotent — safe to re-run.

After it finishes, open a new shell so the home-manager environment is picked up.

## Layout

Each top-level directory is either a stow package (files live at a path mirroring `$HOME`) or a source tree that home-manager reads from.

### Stow Managed
Stowed from `~/dotfiles` into `$HOME`:
- `aerospace` → `~/.config/aerospace/`
- `tmux` → `~/.config/tmux/` (plugins are installed by tpm into a gitignored subdir)
- `nvim` → `~/.config/nvim/`
- `bin` → `~/.local/bin/` (scripts: `tmux-picker`, `workmux-add`, `sessionizer-dirs`, `herdr-sessionizer`, `herdr-split`, `herdr-anchor`, `herdr-nav`, `herdr-plugins`, `herdr-agent-ctx`, `agent-skills`, `agent-scratch`, `stripnl`)
- `nix` → `~/.config/nix/nix.conf` (enables `nix-command` + `flakes`; stowed first so home-manager can run)
- `herdr` → `~/.config/herdr/` (`config.toml` + `plugins.lock.json`)
- `claude` → `~/.claude/` (`CLAUDE.md`, `commands/`, `agents/`, `skills/`)
- `pi` → `~/.pi/agent/` (`settings.json`, `AGENTS.md`, `extensions/command-aliases.ts`)
- `agents` → `~/.agents/skills/` (harness-agnostic skills, the [Agent Skills standard](https://agentskills.io) shared dir)
- `workmux` → `~/.config/workmux/config.yaml` (only does anything on a tmux machine, see [workmux](#workmux))
- `agent-instructions` is not stowed directly — it holds the one canonical
  `AGENTS.md` that the `claude` and `pi` packages both symlink to (see [agent setup](#agent-setup-pi--claude)).

To re-stow everything: `cd ~/dotfiles && stow --restow aerospace tmux nvim bin nix herdr claude pi agents workmux`.

### herdr workspaces

`prefix+f` opens `herdr-sessionizer` in an fzf popup. Pick a directory to focus its
existing workspace or build an `edit` tab running nvim, a `run` tab split into a
scratch shell (top) and the project's server (bottom), and an `agents` tab of three
bare shells. The selected directory is the root, whether it is a repo, a subdirectory
of one, or outside git entirely. Canceling the picker does nothing.

Nothing is started in the agents tab. `herdr agent start` wants a pane already
sitting at a prompt, so the template only makes room. New workspaces are built
unfocused, then focused on `edit` once the layout is complete.

```sh
herdr-sessionizer                      # open the directory picker
herdr-sessionizer ~/code/ts/foo        # skip the picker; build or reuse
herdr-sessionizer . --agents 2         # fewer agent panes
herdr-sessionizer . --server 'just up' # override the detected server command
herdr-sessionizer . --server ''        # leave the server pane at a prompt
herdr-sessionizer . --no-focus         # build or reuse without changing focus
```

Reuse requires a label matching the directory basename *and* a live pane inside the
selected root, so `~/code/go/api` and `~/code/ts/api` don't steal each other's
workspace. Reuse leaves the existing layout and commands alone.

Both `herdr-sessionizer` and `tmux-picker` get their candidate directories from
`sessionizer-dirs`, so the format lives in one place. It reads the machine-local,
gitignored `sessionizer.conf` beside itself as invoked (`~/.local/bin`, not the
checkout its symlink points at). `SESSIONIZER_DIRS` is a zsh array whose entries are
paths, each optionally suffixed `:MIN:MAX` to search that root at those find depths;
a bare path offers just that directory:

```zsh
export SESSIONIZER_DIRS=(~/code:1:2 ~/dotfiles)
```

A bare entry falls back to `MIN_DEPTH` / `MAX_DEPTH` when the conf sets them, so confs
predating per-entry depths keep working. Without a config, both list the immediate
directories in `$HOME`. `prefix+w` and `prefix+s` remain the pickers for what is
already open.

The server command is sniffed from project files (`bin/dev`, a `dev`/`server`
recipe in a justfile or Makefile, `package.json` scripts, `mix.exs`, `manage.py`, hugo,
`go.mod`) and never from `command -v`: the pane's shell enters the project's
direnv/nvm environment, while the script's shell does not. A project's `mix` or
`pnpm` may therefore be runnable in the pane but missing from the script's PATH.
Ambiguous projects (a `cmd/` with two binaries, a `package.json` with no dev/start/serve
script) get no guess and a plain prompt.

`herdr-sessionizer` replaces `herdr-project`. After updating an existing install,
`stow --restow bin` installs the new script and removes the old dangling symlink.

### workmux

[workmux](https://github.com/raine/workmux) pairs a git worktree with a tmux session per branch, which makes it the tmux counterpart to the herdr workspaces above — so it's installed only when the multiplexer is tmux. `nix/flake.nix` (`remote.multiplexer`) stays the single source of truth for that choice: home-manager reads it to decide what to install, and step 7b of `install.sh` reads the same line back out to decide whether to fetch the workmux binary. The config is stowed on every machine regardless; it's an inert yaml file without the binary.

The binary lands in `~/.local/bin` (pinned via `WORKMUX_INSTALL_DIR`, since the upstream installer otherwise prefers `/usr/local/bin` and asks for sudo). After the first install it maintains itself with `workmux update`, so the install step only fires on a machine that has none.

`~/.config/workmux/config.yaml` is a stow symlink into this repo, so `workmux config edit` edits the committed file directly and shows up in `git diff`. Per-project overrides go in a `.workmux.yaml` at the project root (`workmux init`) and belong to that project, not here.

**Run `workmux setup --hooks`.** The hooks half writes the agent status-tracking glue: a pi extension at `~/.pi/agent/extensions/workmux-status.ts` (machine-local, gitignored, owned and versioned by workmux exactly like the herdr integrations) and the `set-window-status` / `register-agent` hooks in `~/.claude/settings.json`, which is machine-local and not committed. It can't run from `install.sh`: it refuses a non-interactive terminal.

The skills half (`workmux setup --skills`) copies workmux's own `/merge`, `/rebase`, `/worktree`, `/coordinator`, `/open-pr` and `/workmux` skills into `~/.pi/agent/skills` and `~/.claude/skills`. None of them are kept in this repo, so they land as machine-local skills. On claude the `workmux-status` plugin already supplies the same six, so `--skills` is only useful for pi.

`workmux-add` (in the `bin` package) is the popup bound to `prefix+G` in `tmux.conf`: it prompts for a name and runs `workmux add`.

### herdr plugins

herdr's own `~/.config/herdr/plugins.json` is a machine-local cache — it bakes in absolute
`/Users/<you>/...` paths and a denormalized copy of each plugin manifest, so it can't be
committed. `herdr/.config/herdr/plugins.lock.json` keeps only the portable part
(`owner/repo@commit`), the same role `lazy-lock.json` plays for Neovim:

```sh
herdr-plugins status   # lockfile vs. what's installed here
herdr-plugins sync     # install/enable to match the lockfile (run by install.sh)
herdr-plugins lock     # after adding/updating a plugin, then commit the lockfile
```

No herdr plugins are installed at the moment, so the lockfile is `[]`. `herdr-plugins lock` refuses to write an empty lockfile, so reset it by hand after removing the last plugin.

### herdr navigation

`ctrl+hjkl` moves focus and `alt+hjkl` resizes across Neovim splits, herdr panes and AeroSpace windows, without plugins. `herdr-nav` (in the `bin` package) handles the herdr side: in a Neovim pane it forwards the chord, otherwise it focuses or resizes the herdr pane, or hands off to AeroSpace at the outer edge. `navigate.nvim`, a local plugin in `nvim/.config/nvim/local/`, handles the Neovim side and calls back into herdr at its edge. Both talk to the herdr server socket (`~/.config/herdr/herdr.sock`, one JSON request per connection) instead of running the `herdr` CLI, because endpoint security makes each `herdr` launch cost ~25 ms.

### claude config

`~/.claude` is a live working directory — Claude Code keeps session transcripts, caches,
plugin installs and `history.jsonl` there — so the package stows only the four things
worth carrying between machines, and leaves the rest machine-local, `settings.json` included:

| path | what it is |
| --- | --- |
| `~/.claude/CLAUDE.md` | symlink → the shared `agent-instructions/AGENTS.md` (see [agent setup](#agent-setup-pi--claude)) |
| `~/.claude/commands/` | slash commands (`foo.md` → `/foo`) |
| `~/.claude/agents/` | subagent definitions (`foo.md` → the `foo` agent type) |
| `~/.claude/skills/` | real dir holding one link per skill in the shared `agents/.agents/skills/` dir, so pi and claude read the same `foo/SKILL.md` skills |

`~/.claude/settings.json` is not committed. Claude Code rewrites it (`/config`, `/model`, plugin installs), and installers such as `herdr integration install claude` and the axi tools can append hooks to it, so it stays a real machine-local file. On a fresh machine, recreate it by hand: the `statusLine` command that feeds the herdr sidebar is `$HOME/.local/bin/herdr-agent-ctx statusline`, and plugins are reinstalled through `/plugin`.

Machine-local secrets belong in `~/.claude/*.env` (not stowed, not committed), referenced
from `settings.json` permissions by path.

### agent setup (pi + claude)

The coding harnesses (Claude Code, pi) are configured to share one set of
instructions and one set of skills, so nothing is written twice. herdr is not a
harness — it's the multiplexer that hosts agent panes — so it has no part in this;
its per-harness hook/extension glue is machine-local and installed by `herdr
integration install` (step 10 of `install.sh`), not committed.

For claude, that installer also *wires* its hook into the machine-local
`~/.claude/settings.json`. It matches an existing entry only by exact string, so a
`$HOME` spelling of the same hook is not recognised and a duplicate is appended on
every run. Step 10 prunes such duplicates afterwards, keeping the first spelling.

**Instructions — one file, two names.** The canonical global instructions live in
`agent-instructions/AGENTS.md`. The `claude` and `pi` packages don't copy it; they
symlink to it, so after stowing you get a two-hop chain that resolves to the one
file:

```
~/.claude/CLAUDE.md   → claude/.claude/CLAUDE.md   → agent-instructions/AGENTS.md
~/.pi/agent/AGENTS.md → pi/.pi/agent/AGENTS.md      → agent-instructions/AGENTS.md
```

pi reads either `AGENTS.md` or `CLAUDE.md`; claude reads only `CLAUDE.md`. Naming
the canonical file `AGENTS.md` is the vendor-neutral choice. Edit either end and
`git diff` shows the change in `agent-instructions/AGENTS.md`; neither harness
*writes* its instructions file, so nothing clobbers the symlinks.

**Skills — one directory.** The canonical skills live in `agents/.agents/skills/` (each skill a `<name>/SKILL.md` folder). pi reads `~/.agents/skills/` natively. The `claude` package's `skills/` is a symlink to the same canonical dir. Both harness dirs are real directories that `install.sh` creates before stowing, so stow fills each with one link per skill:

```
~/.agents/skills/foo  → agents/.agents/skills/foo                          (pi, native)
~/.claude/skills/foo  → claude/.claude/skills/foo → agents/.agents/skills/foo   (claude)
```

A skill that a harness creates on this machine, or that a [third-party bundle](#agent-setup-pi--claude) installs, is written as a real directory beside those links, so it stays machine-local and never reaches the repo. To share it, move it into `agents/.agents/skills/` and re-stow.

**Settings stay separate.** The harness settings schemas differ
(`~/.claude/settings.json` uses `permissions`/`enabledPlugins`; `~/.pi/agent/settings.json`
uses `defaultProvider`/`defaultModel`), so they are *not* unified. pi's is committed in the `pi` package; claude's is machine-local (see [claude config](#claude-config)). The `pi` package commits only `settings.json`, the `AGENTS.md`
symlink, and the `command-aliases.ts` extension; `pi/.pi/.gitignore` keeps the live churn (`sessions/`, `cache/`, `auth.json`,
the other (herdr, workmux) `extensions/`, `models-store.json`) out of the repo, the same discipline the
`claude` package uses.

**Work vs. home.** At work (claude only) stow `claude` + `agents`. At home (pi + claude)
add `pi`. Instructions and skills are identical everywhere; only which harness
packages you stow differs.

**Adding a skill.** Drop a `<name>/SKILL.md` folder in `agents/.agents/skills/`, then run `stow --restow agents claude` to link it into both harness dirs. Restowing also removes the links for skills deleted from the repo. `agent-skills wiring` reports any repo skill that is not linked yet.

**Third-party bundles.** Only skills I wrote or forked live in `agents/.agents/skills/`. Bundles from elsewhere are installed machine-locally with the [`skills` CLI](https://github.com/vercel-labs/skills), and the repo records just their sources in `scripts/skill-bundles.txt`:

```
mattpocock/skills grilling tdd to-spec ...
```

Each line is a source followed by the skills to take from it; a bare source takes the whole bundle. `agent-skills bundles` (run by step 6c of `install.sh`) installs whatever is missing. Each skill becomes a real directory in `~/.agents/skills` with a link from `~/.claude/skills`, beside the stow links, so both harnesses see it and nothing reaches the repo. The CLI tracks versions in the machine-local `~/.agents/.skill-lock.json`:

```sh
agent-skills bundles           # install what the manifest lists and this machine lacks
npx skills ls -g               # what is installed, and from where
npx skills update -g           # pull newer upstream versions
npx skills remove -g -s NAME   # drop one; also delete it from the manifest
```

To try a new bundle, add a line to the manifest and run `agent-skills bundles`. To end the trial, remove its skills with `npx skills remove` and delete the line.

A skill that exists in the repo is never installed from a bundle: its name in `~/.agents/skills` is a stow link, so the CLI would write upstream's copy through the link into this repo. `agent-skills bundles` skips such names. `diagnosing-bugs` and `handoff` are forks of `mattpocock/skills` (copied at `3cca18b`, 2026-09-04) that carry local edits, which is why they stay in the repo and are absent from the manifest.

If a repo skill ever ships helper scripts, it is a self-contained npm project: commit its `package.json` and `package-lock.json`, and ignore its `node_modules` with a `.gitignore` in the skill's own folder. Step 6b of `install.sh` runs `npm ci` for every skill with a `package.json`. `SKIP_SKILL_DEPS=1` skips that step.

`herdr/SKILL.md` is a pointer, not a copy. herdr ships its own agent instructions inside
the binary (`herdr --skill`), so the committed file keeps only the vendor's frontmatter —
the description is what makes an agent reach for the skill at all — and its body tells the
agent to run `herdr --skill` and follow that output. Nothing to regenerate after a `herdr
update`: the release-matched text always comes from the installed binary at the moment
it's used.

### testing the agent setup

`agent-skills` (in the `bin` package) tests this wiring systematically — run it after
authoring a skill or after a re-stow:

```sh
agent-skills            # lint + wiring: fast, free, deterministic. run this constantly.
agent-skills lint       # validate every SKILL.md (name rules, description present/length,
                        #   and whether name matches its dir — which Claude's spec requires)
agent-skills wiring      # stow symlinks resolve to the repo; skills dirs and ~/.pi/agent not folded
agent-skills probe NAME  # launch pi AND claude, load /skill:NAME, report hit/miss (costs API calls)
agent-skills all NAME    # lint + wiring, then probe NAME
agent-skills bundles     # install third-party bundles (see "Third-party bundles" above)
```

The layers map to the failure modes: **lint** catches authoring mistakes without a harness (it reimplements the Agent Skills frontmatter rules, so a malformed skill fails here in milliseconds instead of silently not loading later). **wiring** catches a broken or folded symlink after a re-stow, including the folding trap, by asserting that `~/.pi/agent`, `~/.agents/skills` and `~/.claude/skills` are real directories. For each skills dir it also reports repo skills that are unlinked or shadowed by a local copy, dangling links left by a deleted skill, and the machine-local skills it found. **probe** is the only layer that spends tokens: it invokes each harness's slash command (`/skill:NAME` in pi, `/NAME` in claude) and checks the harness found the skill rather than answering "not available" / "unknown command". `lint` and `wiring` exit non-zero on failure, so `agent-skills` drops into a commit hook or CI step cleanly.

**The folding trap — why `install.sh` runs `mkdir -p` first.** stow *folds* a directory into a single symlink when the target doesn't exist: an absent `~/.pi/agent` becomes one link `~/.pi/agent → pi/.pi/agent` *into this repo*, and pi then writes `sessions/`, `auth.json`, and caches straight through it, dumping runtime state into your dotfiles. So `install.sh` pre-creates the real live dirs (`~/.pi/agent`, `~/.claude`, `~/.agents/skills`, `~/.claude/skills`) *before* stowing, which forces stow to link individual files and leave the rest of each working directory alone. This matters most on a fresh machine where the harness hasn't run yet — on a machine where it already has, the dir exists and folding never triggers. Earlier installs folded the two skills dirs on purpose, so `install.sh` first removes either one if it is a symlink into this repo.

### Nix Managed
Declared in `nix/flake.nix` + `nix/home-manager/*.nix`. Home-manager writes these paths from the nix store:
- `~/.zshrc` (and oh-my-zsh / starship / zoxide / direnv integrations) — `nix/home-manager/zsh.nix`
- `~/.config/kitty/*` — sourced from `kitty/` via `nix/home-manager/home.nix`
- All CLI packages: neovim, stow, fzf, ripgrep, lazygit, postgres, awscli, nerd-fonts, etc. — `nix/home-manager/home.nix`

`~/.config/zsh/local.zsh` is optional and machine-local — put secrets / work-specific config there. It's sourced by `zsh.nix` if present.

### Homebrew Managed
Declared in `Brewfile`, applied by `install.sh` (step 2) with `brew bundle install`.
Homebrew runs *before* Nix so `nvm`, `herdr` and `gh` exist for the later steps.

```sh
brew bundle check  --file=Brewfile --no-upgrade   # anything missing?
brew bundle install --file=Brewfile --no-upgrade  # install what's missing
brew bundle dump   --file=Brewfile --force        # re-record after installing something
```

Two traps when re-dumping — both are called out in the `Brewfile` header:

- **`dump` silently omits formulae from untrusted taps.** `linear` and `lt` vanished from the
  first dump for this reason, so they're listed with their full tap paths. `install.sh` runs
  `brew trust --tap` on `markmarkoh/lt`, `nikitabobko/tap` and `schpet/tap` first; without
  that, Homebrew refuses to load them (and refuses the `aerospace` cask too).
- **`dump` emits `npm`/`go` lines** for global packages. Those need node/go on `PATH`, which
  isn't true when the Brewfile is applied, so they live in `install.sh` step 6 instead.

`nvm` is Homebrew-managed. `zsh.nix` sources it from `/opt/homebrew/opt/nvm/nvm.sh`, falling
back to the Intel prefix and then `$NVM_DIR/nvm.sh`, so a curl-installed nvm still works.
`NVM_DIR` stays `~/.nvm` either way — that's where the node versions live, independent of how
nvm itself was installed. Sourcing nvm costs ~200ms of shell startup; lazy-load it if that
starts to bite.

## Upgrading Nix Packages

```sh
cd ~/dotfiles/nix
nix flake update
hms
```

`hms` is an alias defined in `zsh.nix` for `home-manager switch --impure --flake ~/dotfiles/nix#default`.
