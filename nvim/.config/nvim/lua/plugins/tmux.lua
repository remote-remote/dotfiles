return {
  -- Owns <M-hjkl> under tmux; elsewhere navigate.nvim (plugins/navigate.lua) does.
  { "RyanMillerC/better-vim-tmux-resizer", cond = vim.env.TMUX ~= nil },
}
