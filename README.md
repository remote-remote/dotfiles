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
- `bin` → `~/.local/bin/` (scripts: `ghpr`, `csvify`, `tmux-sessionizer`, `herdr-plugins`, `herdr-anchor`, `herdr-split`)
- `nix` → `~/.config/nix/nix.conf` (enables `nix-command` + `flakes`; stowed first so home-manager can run)
- `herdr` → `~/.config/herdr/` (`config.toml` + `plugins.lock.json`)

To re-stow everything: `cd ~/dotfiles && stow --restow aerospace tmux nvim bin nix herdr`.

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
