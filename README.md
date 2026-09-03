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
- `bin` → `~/.local/bin/` (scripts: `ghpr`, `csvify`, `tmux-sessionizer`, `herdr-plugins`, `herdr-anchor`, `herdr-split`, `herdr-project`)
- `nix` → `~/.config/nix/nix.conf` (enables `nix-command` + `flakes`; stowed first so home-manager can run)
- `herdr` → `~/.config/herdr/` (`config.toml` + `plugins.lock.json`)
- `claude` → `~/.claude/` (`CLAUDE.md`, `settings.json`, `commands/`, `agents/`, `skills/`)

To re-stow everything: `cd ~/dotfiles && stow --restow aerospace tmux nvim bin nix herdr claude`.

### herdr workspaces

`herdr-project <repo>` builds the standard per-repo workspace: an `edit` tab running
nvim, a `run` tab split into a scratch shell (top) and the repo's server (bottom), and
an `agents` tab of three bare shells. Nothing is started in the agents tab — `herdr
agent start` wants a pane already sitting at a prompt, so the template only makes the
room.

```sh
herdr-project ~/code/ts/foo          # build it, or focus it if it's already open
herdr-project . --agents 2           # fewer agent panes
herdr-project . --server 'just up'   # override the detected server command
herdr-project . --server ''          # leave the server pane at a prompt
```

Re-running is safe: a workspace counts as that repo's when its label matches the repo
directory name *and* it still holds a pane inside the repo, so `~/code/go/api` and
`~/code/ts/api` don't steal each other's workspace.

The server command is sniffed from files in the repo (`bin/dev`, a `dev`/`server`
recipe in a justfile or Makefile, `package.json` scripts, `mix.exs`, `manage.py`, hugo,
`go.mod`) and never from `command -v` — the pane's shell picks up direnv/nix/nvm and
the script's shell doesn't, so `mix` can be runnable in the pane while missing from
the script's PATH. Ambiguous repos (a `cmd/` with two binaries, a `package.json` with
no dev script) get no guess and a plain prompt.

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
| `~/.claude/CLAUDE.md` | instructions prepended to every session on this machine |
| `~/.claude/settings.json` | model, effort level, permissions, hooks, enabled plugins |
| `~/.claude/commands/` | slash commands (`foo.md` → `/foo`) |
| `~/.claude/agents/` | subagent definitions (`foo.md` → the `foo` agent type) |
| `~/.claude/skills/` | personal skills (`foo/SKILL.md`); coexists with the symlinks that `find-skills` drops in from `~/.agents/skills/` |

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
