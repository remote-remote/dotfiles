# Global instructions

## This machine

- macOS. Terminal is kitty, editor is neovim, multiplexer is tmux (plus herdr for agent panes).
- `gh` is installed and authenticated — use it for GitHub work instead of scraping the web UI.
- Common languages here: Go, TypeScript/Node, Lua (neovim config), Nix, shell.

## Dotfiles — read before editing anything under `~/.config` or `~/.zshrc`

`~/dotfiles` is the source of truth, split between two mechanisms. Editing the wrong end
either silently does nothing or gets reverted on the next switch.

- **Home-manager generated (read-only symlinks into the nix store):** `~/.zshrc`,
  `~/.config/kitty/*`. Do not edit these paths. Edit the source under
  `~/dotfiles/nix/home-manager/*.nix` (kitty's files live in `~/dotfiles/kitty/`), then
  `home-manager switch --impure --flake ~/dotfiles/nix#default`.
- **Stow symlinks (editable in place, but the file is in git):** `~/.config/nvim`,
  `~/.config/tmux`, `~/.config/aerospace`, `~/.config/herdr`, `~/.local/bin`,
  `~/.claude`. Editing through the symlink edits the repo — so `cd ~/dotfiles && git diff`
  will show it. Prefer editing the repo path directly. New files need
  `stow --restow <pkg>` before they appear in `$HOME`.
- Machine-local secrets go in `~/.config/zsh/local.zsh`, which is gitignored and sourced
  by zsh.nix if present. Never commit them to the repo.

## Validation — scope it to what changed

The repos here get large, and a full-repo typecheck or lint costs minutes to answer a
question about three files. Never run one as a reflex.

- **Type errors: read them from the LSP, don't compile.** `typescript-lsp` and `gopls` are
  enabled — diagnostics for a file are already available without a build. Do not run `tsc`
  or `tsc --noEmit` over a project.
- **Lint the files you touched:** `eslint path/to/changed.ts`. Never `eslint .`, and never
  the package.json `lint`/`typecheck` script, which is almost always repo-wide.
- **Go: name the package.** `go build ./pkg/thing`, `go test ./pkg/thing` — not `./...`.
- A full-repo pass is sometimes genuinely the right call. When it is, say why and ask
  first; don't just start one and let it run.

## Don't be clever

- **Change existing code in place before adding a layer.** No new wrapper, helper, util
  module, interface, or generic unless I asked for one, or three call sites already need it.
- **Match the abstraction level of the file you're in.** If the surrounding code is three
  plain functions, don't arrive with a class hierarchy or a strategy map.
- **No speculative generality.** Don't add options, flags, config, or extension points for
  cases that don't exist yet.
- Prefer the boring, longer version to the compressed clever one. If a reviewer would have
  to stop and work out what a line does, it's the wrong line.

## Working preferences

- Match the surrounding code — its naming, comment density, and idioms — over any general
  style preference.
- When a command's output would answer the question, run it rather than reasoning about
  what it probably prints.
