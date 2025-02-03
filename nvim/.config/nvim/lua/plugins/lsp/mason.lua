return {
	"williamboman/mason.nvim",
	dependencies = {

		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		local mason = require("mason")
		mason.setup({})

		local mason_lspconfig = require("mason-lspconfig")

		mason_lspconfig.setup({
			ensure_installed = {
				"tsserver",
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
}
