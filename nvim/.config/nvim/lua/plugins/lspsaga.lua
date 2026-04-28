return {
  'nvimdev/lspsaga.nvim',
  config = function()
    require('lspsaga').setup({
      lightbulb = {
        enable = false,
      },
      code_action = {
        enable = true,
      },
      symbol_in_winbar = {
        enable = true,
        hide_keyword = false,
        respect_root = false,
      },
      outline = {
        layout = "float",
        detail = false,
        auto_preview = false,
        custom_sort = function(a, b)
          -- Sort by line position (implementation order)
          return a.range.start.line < b.range.start.line
        end,
        keys = {
          toggle_or_jump = "o",
          jump = "<CR>",
          quit = "q",
        },
      },
    })
    vim.keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<CR>", { desc = "Toggle Lspsaga outline" })
  end,
  dependencies = {
    'nvim-treesitter/nvim-treesitter', -- optional
    'nvim-tree/nvim-web-devicons',     -- optional
  }
}
