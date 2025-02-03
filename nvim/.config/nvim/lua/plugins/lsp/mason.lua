return {
	{
		"williamboman/mason.nvim",
		config = function()
			local mason = require("mason")
			mason.setup({})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
		},
		config = function()
			local mason_lspconfig = require("mason-lspconfig")

			mason_lspconfig.setup({
				ensure_installed = {
					"ts_ls",
					"volar",
					"lua_ls",
					"elixirls",
					"ruby_lsp",
					"rust_analyzer",
					"pylsp",
				},
				automatic_installation = true,
			})
		end,
	},
}
