return {
	{
		"FabijanZulj/blame.nvim",
	},
	{
		"tpope/vim-fugitive",
		config = function()
			vim.keymap.set("n", "<leader>gg", vim.cmd.Git)
		end,
	},
	{
		"sindrets/diffview.nvim",
		config = function()
			require("diffview").setup()

			vim.keymap.set("n", "<leader>gdw", "<cmd>DiffviewClose<CR>")
			vim.keymap.set("n", "<leader>gdd", "<cmd>DiffviewOpen<CR>")
			vim.keymap.set("n", "<leader>gdm", "<cmd>DiffviewOpen main<CR>")
			vim.keymap.set("n", "<leader>gdf", "<cmd>DiffviewFileHistory %<CR>")
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
}
