#!/usr/bin/env bash
# Bootstrap a fresh macOS machine from this dotfiles repo.
#
# Layout assumption: this repo is cloned at ~/dotfiles (override with DOTFILES=...).
# Safe to re-run — each step is idempotent.

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
STOW_PACKAGES=(nix aerospace tmux nvim bin herdr)

log() { printf '\n==> %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

if [ "$(uname)" != "Darwin" ]; then
  echo "This bootstrap targets macOS. Aborting." >&2
  exit 1
fi

if [ ! -d "$DOTFILES" ]; then
  echo "Expected repo at $DOTFILES. Clone it first or set DOTFILES=<path>." >&2
  exit 1
fi

cd "$DOTFILES"

# 1. Xcode Command Line Tools — needed for git, compilers, etc.
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools"
  xcode-select --install
  echo "Re-run this script once the CLT installer finishes."
  exit 0
fi

# 2. Homebrew + Brewfile. Runs before Nix so `nvm`, `herdr`, `gh` and the casks
#    exist for the later steps. UNTRUSTED_TAPS must be trusted first: Homebrew
#    refuses to load third-party tap formulae without it, and `brew bundle dump`
#    silently omits them (see the note at the top of ../Brewfile).
UNTRUSTED_TAPS=(markmarkoh/lt nikitabobko/tap schpet/tap)

if ! have brew; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

for shellenv in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [ -x "$shellenv" ] && eval "$("$shellenv" shellenv)" && break
done

log "Trusting third-party taps"
for tap in "${UNTRUSTED_TAPS[@]}"; do
  brew trust --tap "$tap"
done

log "Installing Brewfile packages"
brew bundle install --file="$DOTFILES/Brewfile" --no-upgrade

# 3. Nix (Determinate installer). Source the profile so this shell sees it.
if ! have nix; then
  log "Installing Nix"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
fi

for profile in \
  /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
  "$HOME/.nix-profile/etc/profile.d/nix.sh"; do
  [ -f "$profile" ] && . "$profile"
done

# 4. Stow packages. `nix` goes first so ~/.config/nix/nix.conf enables flakes
#    before we invoke home-manager. Uses nix-shell to borrow stow until
#    home-manager installs its own copy.
STOW=(stow)
if ! have stow; then
  STOW=(nix-shell --extra-experimental-features 'nix-command flakes' -p stow --run stow)
fi

mkdir -p "$HOME/.config" "$HOME/.local/bin"

for pkg in "${STOW_PACKAGES[@]}"; do
  log "Stowing $pkg"
  "${STOW[@]}" --dir="$DOTFILES" --target="$HOME" --restow "$pkg"
done

# 5. Home Manager — installs all packages, kitty config, zsh setup, etc.
log "Running home-manager switch"
if ! have home-manager; then
  nix --extra-experimental-features 'nix-command flakes' \
    run home-manager/master -- \
    init --switch --impure --flake "$DOTFILES/nix#default"
else
  home-manager switch --impure --flake "$DOTFILES/nix#default"
fi

# 6. Language-manager globals. nvm comes from Homebrew (step 2) and go from
#    home-manager (step 5), so this has to run after both. These are the
#    `npm`/`go` entries that `brew bundle dump` emits but the Brewfile omits,
#    because applying them requires a toolchain the Brewfile itself installs.
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
for nvm_sh in /opt/homebrew/opt/nvm/nvm.sh /usr/local/opt/nvm/nvm.sh "$NVM_DIR/nvm.sh"; do
  if [ -s "$nvm_sh" ]; then . "$nvm_sh"; break; fi
done

if command -v nvm >/dev/null 2>&1; then
  log "Installing node + global npm packages"
  nvm install 22
  nvm alias default 22
  npm install -g corepack @earendil-works/pi-coding-agent
else
  echo "nvm not loaded; skipping node setup" >&2
fi

if have go; then
  log "Installing go globals"
  go install github.com/remote-remote/flow@latest
fi

# 7. tmux plugin manager + plugins.
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  log "Installing tmux plugin manager"
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  "$TPM_DIR/bin/install_plugins"
fi

# 8. herdr plugins — replayed from herdr/.config/herdr/plugins.lock.json.
#    herdr's own plugins.json is machine-local (absolute paths), so it isn't
#    committed; `herdr-plugins lock` regenerates the portable lockfile.
if have herdr; then
  log "Syncing herdr plugins"
  "$HOME/.local/bin/herdr-plugins" sync || echo "herdr plugin sync failed; run 'herdr-plugins status' to inspect" >&2
else
  echo "herdr not installed; skipping plugin sync (check the Brewfile step, then: herdr-plugins sync)" >&2
fi

log "Done."
cat <<'EOF'

Next steps:
  - Open a new shell (or `exec zsh`) to pick up the home-manager environment.
  - Optional: create ~/.config/zsh/local.zsh for machine-local secrets/aliases.
  - Optional: create ~/dotfiles/bin/.local/bin/sessionizer.conf to set
    SESSIONIZER_DIRS / MIN_DEPTH / MAX_DEPTH for tmux-sessionizer.
EOF
