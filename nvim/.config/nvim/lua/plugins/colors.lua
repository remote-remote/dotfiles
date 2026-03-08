return {
  "EdenEast/nightfox.nvim",
  "metalelf0/black-metal-theme-neovim",
  "savq/melange-nvim",
  "AlexvZyl/nordic.nvim",
  "rebelot/kanagawa.nvim",
  "RRethy/base16-nvim",
  "morhetz/gruvbox",
  "rose-pine/neovim",
  "vague-theme/vague.nvim",
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
