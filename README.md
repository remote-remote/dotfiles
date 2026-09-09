# dotfiles

macOS setup managed by a mix of [Nix + home-manager](https://nix-community.github.io/home-manager/) and [GNU Stow](https://www.gnu.org/software/stow/).

## Initial Install

Clone this repo to `~/dotfiles`, then run:

```sh
~/dotfiles/scripts/install.sh
```

The script installs Xcode CLT, Homebrew + the Brewfile, Nix, stows the config packages below, runs home-manager, installs node/go globals, then tpm + tmux plugins and herdr plugins. It's idempotent — safe to re-run.

After it finishes, open a new shell so the home-manager environment is picked up.

## Layout

Each top-level directory is either a stow package (files live at a path mirroring `$HOME`) or a source tree that home-manager reads from.

### Stow Managed
Stowed from `~/dotfiles` into `$HOME`:
- `aerospace` → `~/.config/aerospace/`
- `tmux` → `~/.config/tmux/` (plugins are installed by tpm into a gitignored subdir)
- `nvim` → `~/.config/nvim/`
- `bin` → `~/.local/bin/` (scripts: `ghpr`, `csvify`, `tmux-sessionizer`, `herdr-plugins`, `herdr-anchor`, `herdr-split`, `herdr-sessionizer`, `agent-skills`)
- `nix` → `~/.config/nix/nix.conf` (enables `nix-command` + `flakes`; stowed first so home-manager can run)
- `herdr` → `~/.config/herdr/` (`config.toml` + `plugins.lock.json`)
- `claude` → `~/.claude/` (`CLAUDE.md`, `settings.json`, `commands/`, `agents/`, `skills/`)
- `pi` → `~/.pi/agent/` (`settings.json` + `AGENTS.md`)
- `agents` → `~/.agents/skills/` (harness-agnostic skills, the [Agent Skills standard](https://agentskills.io) shared dir)
- `agent-instructions` is not stowed directly — it holds the one canonical
  `AGENTS.md` that the `claude` and `pi` packages both symlink to (see [agent setup](#agent-setup-pi--claude)).

To re-stow everything: `cd ~/dotfiles && stow --restow aerospace tmux nvim bin nix herdr claude pi agents`.

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

Both `herdr-sessionizer` and `tmux-sessionizer` read the machine-local, gitignored
`bin/.local/bin/sessionizer.conf`: `SESSIONIZER_DIRS` is a zsh array of search roots;
`MIN_DEPTH` and `MAX_DEPTH` are find depths relative to those roots. Without a config,
herdr-sessionizer lists immediate directories in `$HOME` (both depths default to 1).
Set all three values for your project layout when creating the shared config.
`prefix+w` and `prefix+s` remain the pickers for what is already open.

The server command is sniffed from project files (`bin/dev`, a `dev`/`server`
recipe in a justfile or Makefile, `package.json` scripts, `mix.exs`, `manage.py`, hugo,
`go.mod`) and never from `command -v`: the pane's shell enters the project's
direnv/nvm environment, while the script's shell does not. A project's `mix` or
`pnpm` may therefore be runnable in the pane but missing from the script's PATH.
Ambiguous projects (a `cmd/` with two binaries, a `package.json` with no dev/start/serve
script) get no guess and a plain prompt.

`herdr-sessionizer` replaces `herdr-project`. After updating an existing install,
`stow --restow bin` installs the new script and removes the old dangling symlink.

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

Note: `herdr-splits` and `herdr-nvim` ship **both** a herdr plugin and a Neovim plugin from
the same repo, so each is pinned twice — once here and once in `lazy-lock.json`. Re-run
`herdr-plugins lock` after `:Lazy update` (or vice versa) so the two commits don't drift.

### claude config

`~/.claude` is a live working directory — Claude Code keeps session transcripts, caches,
plugin installs and `history.jsonl` there — so the package stows only the four things
worth carrying between machines, and leaves the rest machine-local:

| path | what it is |
| --- | --- |
| `~/.claude/CLAUDE.md` | symlink → the shared `agent-instructions/AGENTS.md` (see [agent setup](#agent-setup-pi--claude)) |
| `~/.claude/settings.json` | model, effort level, permissions, hooks, enabled plugins |
| `~/.claude/commands/` | slash commands (`foo.md` → `/foo`) |
| `~/.claude/agents/` | subagent definitions (`foo.md` → the `foo` agent type) |
| `~/.claude/skills/` | symlink → the shared `agents/.agents/skills/` dir, so pi and claude read the same `foo/SKILL.md` skills |

Two things to know:

- **Claude Code writes to `settings.json` itself** — `/config`, `/model`, installing a
  plugin. Those writes land in this repo through the symlink, so they show up in
  `git diff`. Good (nothing drifts silently), but check `git status` before committing,
  and re-run `stow --restow claude` if a write ever replaces the symlink with a real file.
- **`enabledPlugins` is committed, but the plugin *installs* are not** — they live in the
  gitignored `~/.claude/plugins/`. On a fresh machine, run `/plugin` and install the
  marketplace plugins listed in `settings.json`.

Machine-local secrets belong in `~/.claude/*.env` (not stowed, not committed), referenced
from `settings.json` permissions by path.

### agent setup (pi + claude)

The coding harnesses (Claude Code, pi) are configured to share one set of
instructions and one set of skills, so nothing is written twice. herdr is not a
harness — it's the multiplexer that hosts agent panes — so it has no part in this;
its per-harness hook/extension glue is machine-local and installed by `herdr
integration install` (step 10 of `install.sh`), not committed.

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

**Skills — one directory.** The canonical skills live in `agents/.agents/skills/`
(each skill a `<name>/SKILL.md` folder). pi reads `~/.agents/skills/` natively; the
`claude` package symlinks its whole `skills/` dir at the same canonical dir, so both
harnesses see the same folders with no per-skill `find-skills` bridge:

```
~/.agents/skills      → agents/.agents/skills               (pi, native)
~/.claude/skills      → claude/.claude/skills → agents/.agents/skills   (claude)
```

**Settings stay separate.** The harness settings schemas differ
(`~/.claude/settings.json` uses `permissions`/`enabledPlugins`; `~/.pi/agent/settings.json`
uses `defaultProvider`/`defaultModel`), so they are *not* unified — each is committed
in its own package. The `pi` package commits only `settings.json` and the `AGENTS.md`
symlink; `pi/.pi/.gitignore` keeps the live churn (`sessions/`, `cache/`, `auth.json`,
herdr's `extensions/`, `models-store.json`) out of the repo, the same discipline the
`claude` package uses.

**Work vs. home.** At work (claude only) stow `claude` + `agents`. At home (pi + claude)
add `pi`. Instructions and skills are identical everywhere; only which harness
packages you stow differs.

**Adding a skill.** Drop a `<name>/SKILL.md` folder in `agents/.agents/skills/`. Because
`~/.agents/skills` and `~/.claude/skills` are both whole-directory symlinks to that
dir, the skill is live in both harnesses immediately — no re-stow. (pi will even
scaffold new skills straight into the repo path when asked.) `agents/.agents/skills`
is the one folder in the repo intentionally left foldable by stow; `install.sh`
pre-creates every *other* harness dir but only `mkdir -p ~/.agents` so stow folds
`skills` into a single link.

**Vendored skills.** Some skills came from elsewhere and were copied in, not linked or
submoduled: they're short enough to read, and the point is to edit them for my own use.
Once copied they're mine — no upstream sync, `git log` is the history. Origins, so a
future diff against upstream is still possible:

| skills | upstream | copied at |
| --- | --- | --- |
| `brave-search`, `browser-tools`, `gccli`, `gdcli`, `gmcli`, `transcribe`, `youtube-transcript` | [badlogic/pi-skills](https://github.com/badlogic/pi-skills) | `90bb51c` (2026-06-06) |

Those seven are the ones worth having here; upstream's `vscode` skill is skipped (this is
a neovim setup). `brave-search` and `transcribe` want API keys; those belong in
`~/.config/zsh/local.zsh`, never the repo.

A skill that ships helper scripts is a self-contained npm project: its `package.json` and
`package-lock.json` are committed, its `node_modules` is ignored by a `.gitignore` in the
skill's own folder (not a root glob, so the folder stays portable if it's ever copied
out). Step 6b of `install.sh` walks every skill with a `package.json` and runs `npm ci`,
skipping ones whose `node_modules` is already newer than both manifests — so it's cheap to
re-run and still picks up a lockfile bump. `SKIP_SKILL_DEPS=1` skips the step entirely;
worth it when you don't want `browser-tools` dragging in puppeteer + Chromium.

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
agent-skills wiring      # every stow symlink resolves to one source; ~/.pi/agent not folded
agent-skills probe NAME  # launch pi AND claude, load /skill:NAME, report hit/miss (costs API calls)
agent-skills all NAME    # lint + wiring, then probe NAME
```

The layers map to the failure modes: **lint** catches authoring mistakes without a
harness (it reimplements the Agent Skills frontmatter rules, so a malformed skill
fails here in milliseconds instead of silently not loading later). **wiring** catches
a broken or folded symlink after a re-stow — including the folding trap, by asserting
`~/.pi/agent` is still a real directory. **probe** is the only layer that spends tokens:
it invokes each harness's slash command (`/skill:NAME` in pi, `/NAME` in claude) and
checks the harness found the skill rather than answering "not available" / "unknown
command". `lint` and `wiring` exit non-zero on failure, so `agent-skills` drops into a
commit hook or CI step cleanly.

**The folding trap — why `install.sh` runs `mkdir -p` first.** stow *folds* a
directory into a single symlink when the target doesn't exist: an absent
`~/.pi/agent` becomes one link `~/.pi/agent → pi/.pi/agent` *into this repo*, and pi
then writes `sessions/`, `auth.json`, and caches straight through it, dumping
runtime state into your dotfiles. So `install.sh` pre-creates the real live dirs
(`~/.pi/agent`, `~/.claude`, `~/.agents/skills`) *before* stowing, which forces
stow to link individual files and leave the rest of each working directory alone.
This matters most on a fresh machine where the harness hasn't run yet — on a
machine where it already has, the dir exists and folding never triggers.

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
