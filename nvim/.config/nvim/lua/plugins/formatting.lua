return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },

		config = function()
			local conform = require("conform")
			local formatters = {
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
				sass = {
					"prettier",
				},
			}
			if vim.fn.executable("rubocop") == 1 then
				formatters.ruby = { cmd = "rubocop" }
			end

			conform.setup({
				formatters_by_ft = formatters,
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
	},
	{
		"zapling/mason-conform.nvim",
		config = function()
			local ensure_installed = {
				"stylua",
			}
			if vim.fn.executable("node") then
				table.insert(ensure_installed, "prettier")
			end
			require("mason-conform").setup({
				ensure_installed = ensure_installed,
				automatic_installation = true,
			})
		end,
	},
}
