return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		-- file operations?
	},
	config = function()
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
		--
		function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
			opts = opts or {}
			opts.border = opts.border or "rounded"
			return orig_util_open_floating_preview(contents, syntax, opts, ...)
		end

		local keymap = vim.keymap

		local opts = { noremap = true, silent = true }
		local on_attach = function(client, bufnr)
			opts.buffer = bufnr

			-- set keybinds
			opts.desc = "Show LSP references"
			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

			opts.desc = "Go to declaration"
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

			opts.desc = "Show LSP definitions"
			keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

			opts.desc = "See available code actions"
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

			opts.desc = "Smart rename"
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

			opts.desc = "Show buffer diagnostics"
			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

			-- local function parse_ts_type(type)
			-- 	-- need to figure this out, lua has some whack string manipulation
			-- 	type = type.gsub(type, "{", "{\n\t")
			-- 	type = type.gsub(type, "}", "\n}")
			-- 	type = type.gsub(type, ";", "\n")
			-- 	return type
			-- end

			opts.desc = "Show line diagnostics"
			keymap.set("n", "<leader>d", function()
				vim.diagnostic.open_float({
					border = "rounded",
					source = "if_many",
					format = function(raw)
						return raw.message
						-- local result = ""
						-- for line in string.gmatch(raw.message, "[^\n]+") do
						-- 	for arg, arg_type, param, param_type in
						-- 		string.gmatch(line, "([^\n]+)'([^']+)'([^\n]+)'([^']+)'")
						-- 	do
						-- 		if arg and arg_type then
						-- 			result = result .. arg .. "\n```\n" .. parse_ts_type(arg_type) .. "\n```\n"
						-- 		end
						-- 		if param and param_type then
						-- 			result = result .. param .. "\n```\n" .. parse_ts_type(param_type) .. "\n```\n"
						-- 		end
						-- 	end
						-- end
						-- return result
					end,
				})
			end, opts) -- show diagnostics for line

			opts.desc = "Go to previous diagnostic"
			keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

			opts.desc = "Go to next diagnostic"
			keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

			opts.desc = "Show documentation for what is under cursor"
			keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

			opts.desc = "Restart LSP"
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
		end

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		lspconfig["tailwind-tools"].setup({
			capabilities = capabilities,
			filetypes = { "html", "css", "elixir", "typescript" },
			on_attach = on_attach,
		})

		lspconfig["pylsp"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig["csharp_ls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig["ols"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig["lua_ls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = { -- custom settings for lua
				Lua = {
					-- make the language server recognize "vim" global
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						-- make language server aware of runtime files
						library = {
							[vim.fn.expand("$VIMRUNTIME/lua")] = true,
							[vim.fn.stdpath("config") .. "/lua"] = true,
						},
					},
				},
			},
		})

		lspconfig["ruby_lsp"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- lspconfig["rubocop"].setup({
		-- 	capabilities = capabilities,
		-- 	filetypes = { "ruby" },
		-- 	on_attach = on_attach,
		-- 	cmd = { "rubocop", "--lsp" },
		-- 	root_dir = lspconfig.util.root_pattern("Gemfile", ".git"),
		-- })

		lspconfig["rust_analyzer"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- lspconfig["emmet_ls"].setup({
		-- 	capabilities = capabilities,
		-- 	filetypes = { "html", "css", "javascript", "typescript", "vue", "elixir" },
		-- 	on_attach = on_attach,
		-- })

		lspconfig["elixirls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			cmd = { "elixir-ls" },
		})

		-- lspconfig["volar"].setup({
		-- 	capabilities = capabilities,
		-- 	filetypes = {},
		-- 	on_attach = on_attach,
		-- 	init_options = {
		-- 		vue = {
		-- 			hybridMode = false,
		-- 		},
		-- 	},
		-- })

		local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
		local volar_path = mason_packages .. "/vue-language-server/node_modules/@vue/language-server"

		lspconfig["ts_ls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			init_options = {
				plugins = {
					{
						name = "@vue/typescript-plugin",
						location = volar_path,
						languages = { "vue" },
					},
				},
			},
			filetypes = { "javascript", "typescript", "vue" },
		})
	end,
}
