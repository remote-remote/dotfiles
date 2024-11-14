return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },

	config = function()
		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				javascript = {
					"prettier",
				},
				json = {
					"prettier",
				},
				vue = {
					"prettier",
				},
				typescript = {
					"prettier",
				},
				markdown = {
					"prettier",
				},
				lua = {
					"stylua",
				},
				python = {
					"black",
				},
				ruby = {
					"rubocop",
				},
				sass = {
					"prettier",
				},
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout = 1000,
			},
		})

		-- 		vim.keymap.set({
		-- 			{ "n", "<leader>mp", "<cmd>lua require('conform').format()<cr>" },
		-- 		})
	end,
}
