return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	-- enabled = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			update_focused_file = {
				enable = true,
			},
		})

		vim.keymap.set("n", "<leader>e", "<cmd> NvimTreeToggle<cr>")
	end,
}
