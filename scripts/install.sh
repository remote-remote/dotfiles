#!/usr/bin/env bash
# Bootstrap a fresh macOS machine from this dotfiles repo.
#
# Layout assumption: this repo is cloned at ~/dotfiles (override with DOTFILES=...).
# Safe to re-run — each step is idempotent.

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
STOW_PACKAGES=(nix aerospace tmux nvim bin)

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

# 2. Nix (Determinate installer). Source the profile so this shell sees it.
if ! have nix; then
  log "Installing Nix"
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
fi

for profile in \
  /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh \
  "$HOME/.nix-profile/etc/profile.d/nix.sh"; do
  [ -f "$profile" ] && . "$profile"
done

# 3. Stow packages. `nix` goes first so ~/.config/nix/nix.conf enables flakes
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

# 4. Home Manager — installs all packages, kitty config, zsh setup, etc.
log "Running home-manager switch"
if ! have home-manager; then
  nix --extra-experimental-features 'nix-command flakes' \
    run home-manager/master -- \
    init --switch --impure --flake "$DOTFILES/nix#default"
else
  home-manager switch --impure --flake "$DOTFILES/nix#default"
fi

# 5. tmux plugin manager + plugins.
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  log "Installing tmux plugin manager"
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  "$TPM_DIR/bin/install_plugins"
fi

log "Done."
cat <<'EOF'

Next steps:
  - Open a new shell (or `exec zsh`) to pick up the home-manager environment.
  - Optional: create ~/.config/zsh/local.zsh for machine-local secrets/aliases.
  - Optional: create ~/dotfiles/bin/.local/bin/sessionizer.conf to set
    SESSIONIZER_DIRS / MIN_DEPTH / MAX_DEPTH for tmux-sessionizer.
EOF
