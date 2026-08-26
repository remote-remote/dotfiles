# Homebrew state for a fresh machine. Applied by scripts/install.sh via
#   brew bundle install --file=Brewfile
#
# Regenerate with: brew bundle dump --file=Brewfile --force
#
# Two things `brew bundle dump` gets wrong here, so check them after a dump:
#
#  1. It SILENTLY OMITS formulae from untrusted taps. `linear` and `lt` were
#     both dropped on the last dump and are listed explicitly below. install.sh
#     runs `brew trust` on the third-party taps first — without that, brew
#     refuses to load them and these lines fail.
#  2. It emits `npm`/`go` entries for globally-installed packages. Those need
#     node/go on PATH, which doesn't hold when this file is applied, so they
#     live in install.sh (step 4) instead and are omitted here.

tap "markmarkoh/lt"
tap "nikitabobko/tap"
tap "schpet/tap"

# GitHub command-line tool
brew "gh"
# Agent multiplexer that lives in your terminal
brew "herdr"
# Configurable static site generator
brew "hugo"
# Manage multiple Node.js versions
brew "nvm"
# Cryptography and SSL/TLS Toolkit
brew "openssl@3"
# Safe, concurrent, practical language
brew "rust"
# Cross-platform C++ GUI toolkit - required for Elixir inspector
brew "wxwidgets"
# CLI for linear.app driven by git branch / directory names (untrusted tap)
brew "schpet/tap/linear"
# Unofficial TUI client for Linear.app issues (untrusted tap)
brew "markmarkoh/lt/lt"

# Tiling window manager (untrusted tap)
cask "aerospace"
cask "font-hack-nerd-font"
# Keyboard customiser
cask "karabiner-elements"
# Open-source keystroke visualiser
cask "keycastr"
