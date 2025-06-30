return {
	"EdenEast/nightfox.nvim",
	"savq/melange-nvim",
	"AlexvZyl/nordic.nvim",
	"rebelot/kanagawa.nvim",
	"morhetz/gruvbox",
	"rose-pine/neovim",
	"catppuccin/nvim",
	{
		"sainnhe/everforest",
		init = function()
			print("everforest init")
			vim.g.everforest_background = "hard"
		end,
	},
}
