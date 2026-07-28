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
        -- vague.nvim removed its utilities module; blend two hex colors ourselves
        local function blend(fg, bg, alpha)
          local function rgb(c)
            return tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16)
          end
          local fr, fg_, fb = rgb(fg)
          local br, bg_, bb = rgb(bg)
          return string.format(
            "#%02x%02x%02x",
            math.floor(fr * alpha + br * (1 - alpha) + 0.5),
            math.floor(fg_ * alpha + bg_ * (1 - alpha) + 0.5),
            math.floor(fb * alpha + bb * (1 - alpha) + 0.5)
          )
        end
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
    "catgoose/nvim-colorizer.lua",
    init = function()
      vim.opt.termguicolors = true
      require("colorizer").setup()
    end
  }
}
