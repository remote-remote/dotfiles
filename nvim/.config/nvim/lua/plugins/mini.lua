return {
  -- {
  --   "echasnovski/mini.statusline",
  --   version = "*",
  --   config = function()
  --     require("mini.statusline").setup()
  --   end,
  -- },
  {
    'echasnovski/mini.comment',
    version = '*',
    config = function()
      require('mini.comment').setup()
    end
  },
  -- {
  --   'echasnovski/mini.files',
  --   version = '*',
  --   config = function()
  --     require('mini.files').setup()
  --     vim.keymap.set('n', '<leader>-', MiniFiles.open)
  --   end
  -- },
}
