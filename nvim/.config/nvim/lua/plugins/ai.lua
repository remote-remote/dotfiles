return {
	--{
	-- "augmentcode/augment.vim",
	-- config = function()
	--   vim.g.augment_workspace_folders = { "~/ct/r/sysman", "~/ct/r/dashboard-v2" }
	--   vim.keymap.set({ "n", "v" }, "<leader>aic", "<cmd>Augment chat<CR>")
	--   vim.keymap.set("n", "<leader>ait", "<cmd>Augment chat-toggle<CR>")
	--   vim.keymap.set("n", "<leader>ain", "<cmd>Augment chat-new<CR>")
	-- end,
	-- },
	--  {
	-- 	"greggh/claude-code.nvim",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim", -- Required for git operations
	-- 	},
	-- 	config = function()
	-- 		require("claude-code").setup()
	-- 	end
	-- },
	{
		"supermaven-inc/supermaven-nvim",
		config = function()
			require("supermaven-nvim").setup({})
		end,
	},
}
