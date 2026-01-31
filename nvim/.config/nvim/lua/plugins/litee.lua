return {
  {
    'ldelossa/litee.nvim',
    event = "VeryLazy",
    opts = {
      notify = { enabled = false },
      -- panel = {
      --   orientation = "bottom",
      --   panel_size = 10,
      -- },
    },
    config = function(_, opts)
      require('litee.lib').setup(opts)

      vim.keymap.set('n', '<leader>cti', vim.lsp.buf.incoming_calls)
      vim.keymap.set('n', '<leader>cto', vim.lsp.buf.outgoing_calls)
    end
  },
  {
    'ldelossa/litee-calltree.nvim',
    dependencies = 'ldelossa/litee.nvim',
    event = "VeryLazy",
    opts = {
      on_open = "panel",
      map_resize_keys = false,
    },
    config = function(_, opts) require('litee.calltree').setup(opts) end
  },
  {
    'ldelossa/litee-symboltree.nvim',
    dependencies = 'ldelossa/litee.nvim',
    event = "VeryLazy",
    config = function(_, _) require('litee.symboltree').setup({}) end
  },
  {
    'ldelossa/litee-bookmarks.nvim',
    dependencies = 'ldelossa/litee.nvim',
    event = "VeryLazy",
    config = function(_, _) require('litee.bookmarks').setup({}) end
  },
}
