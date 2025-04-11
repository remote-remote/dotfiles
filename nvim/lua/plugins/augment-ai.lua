return {
	"augmentcode/augment.vim",
	config = function()
		print("Augment config")
		vim.g.augment_workspace_folders = { "~/ct/r/sysman", "~/ct/r/dashboard-v2" }
		vim.keymap.set({ "n", "v" }, "<leader>aic", "<cmd>Augment chat<CR>")
		vim.keymap.set("n", "<leader>ait", "<cmd>Augment chat-toggle<CR>")
		vim.keymap.set("n", "<leader>ain", "<cmd>Augment chat-new<CR>")
	end,
}
