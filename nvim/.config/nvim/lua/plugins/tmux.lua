return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    init = function()
      if vim.env.HERDR_PANE_ID ~= nil then
        vim.g.tmux_navigator_no_mappings = 1
      end
    end,
    cond = function()
      return vim.env.HERDR_PANE_ID == nil
    end
  },
  { "RyanMillerC/better-vim-tmux-resizer" },
}
