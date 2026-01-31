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
        custom_sort = function(a, b)
          -- Sort by line position (implementation order)
          return a.range.start.line < b.range.start.line
        end,
        keys = {
          toggle_or_jump = "o",
          quit = "q",
        },
      },
    })
  end,
  dependencies = {
    'nvim-treesitter/nvim-treesitter', -- optional
    'nvim-tree/nvim-web-devicons',     -- optional
  }
}
