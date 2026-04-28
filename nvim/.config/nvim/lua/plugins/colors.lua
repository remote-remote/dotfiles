return {
  "EdenEast/nightfox.nvim",
  "metalelf0/black-metal-theme-neovim",
  "savq/melange-nvim",
  "AlexvZyl/nordic.nvim",
  "rebelot/kanagawa.nvim",
  "RRethy/base16-nvim",
  "morhetz/gruvbox",
  "rose-pine/neovim",
  {
    "vague-theme/vague.nvim",
    opts = {
      colors = {
        bg = "#000000",
      },
      on_highlights = function(highlights, colors)
        local blend = require("vague.utilities").blend
        highlights.DiffAdd = { bg = blend(colors.plus, colors.bg, 0.3) }
        highlights.DiffChange = { bg = blend(colors.delta, colors.bg, 0.2) }
        highlights.DiffDelete = { bg = blend(colors.error, colors.bg, 0.3) }
      end,
    },
  },
  "catppuccin/nvim",
  {
    "sainnhe/everforest",
    init = function()
      vim.g.everforest_background = "hard"
    end,
  },
  "sho-87/kanagawa-paper",
  "datsfilipe/vesper.nvim",
  {
    "norcalli/nvim-colorizer.lua",
    init = function()
      vim.opt.termguicolors = true
      require("colorizer").setup()
    end
  }
}
