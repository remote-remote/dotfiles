# Dotfiles

`~/dotfiles` is the source of truth for managed personal configuration. Edit repo sources rather than installed paths. Configuration is installed through either Home-manager or GNU Stow.

## Home-manager

Generated files are read-only symlinks into the Nix store. Do not edit them directly.

- `~/.zshrc`: edit `nix/home-manager/zsh.nix`.
- `~/.config/kitty/*`: edit the source files in `kitty/`; their Home-manager wiring lives in `nix/home-manager/home.nix`.
- Other Home-manager configuration lives under `nix/home-manager/` and in `nix/flake.nix`.

Editing configuration does not authorize activating it. Run Home-manager or change installed symlinks only when the user requests activation.

## Stow

Stow packages mirror paths under `$HOME`. Editing an installed symlink edits the repo, but prefer the repo path directly. Some destination directories also contain machine-local files that are not managed here.

| Package | Destination |
| --- | --- |
| `aerospace` | `~/.config/aerospace/` |
| `tmux` | `~/.config/tmux/` |
| `nvim` | `~/.config/nvim/` |
| `bin` | `~/.local/bin/` |
| `nix` | `~/.config/nix/nix.conf` |
| `herdr` | `~/.config/herdr/` |
| `workmux` | `~/.config/workmux/config.yaml` |
| `claude` | Managed files and symlinks in `~/.claude/` |
| `pi` | `~/.pi/agent/settings.json` and `~/.pi/agent/AGENTS.md` |
| `agents` | `~/.agents/skills/` |

New files may need `stow --restow <pkg>` from `~/dotfiles` to appear in `$HOME`. Files added inside an already symlinked directory, such as the shared skills directory, appear immediately. Check the existing links before restowing.

## Shared agent instructions and skills

`agent-instructions/AGENTS.md` is the canonical global instructions file. Both `~/.claude/CLAUDE.md` and `~/.pi/agent/AGENTS.md` resolve to it through their Stow packages. Keep it harness-neutral. This root `AGENTS.md` contains repo-specific guidance, not global instructions.

Shared skills live in `agents/.agents/skills/`, exposed through `~/.agents/skills` and `~/.claude/skills`. Harness settings remain separate. See the README's [agent setup section](README.md#agent-setup-pi--claude) for the wiring and checks.

## Secrets

Machine-local shell secrets belong in `~/.config/zsh/local.zsh`, which is gitignored and sourced by `zsh.nix` if present. Never commit secrets to the repo.
