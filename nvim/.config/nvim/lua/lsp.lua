vim.lsp.enable({ "elixir_ls", "lua_ls", "ruby_lsp", "ts_ls", "vue_ls" })

local opts = { noremap = true, silent = true }
local keymap = vim.keymap

vim.lsp.config("*", {
  on_attach = function(client, bufnr)
    if client:supports_method('textDocument/completion') then
      -- Optional: trigger autocompletion on EVERY keypress. May be slow!
      local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end

    opts.buffer = bufnr

    -- set keybinds
    opts.desc = "Show LSP references"
    keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

    opts.desc = "Go to declaration"
    keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

    opts.desc = "Show LSP definitions"
    keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- show lsp definitions

    opts.desc = "Show LSP implementations"
    keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

    opts.desc = "See available code actions"
    keymap.set({ "n", "v" }, "<leader>ca", function() vim.lsp.buf.code_action() end, opts) -- see available code actions, in visual mode will apply to selection

    opts.desc = "Smart rename"
    keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

    opts.desc = "Show buffer diagnostics"
    keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

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
    keymap.set("n", "K", function()
      vim.lsp.buf.hover({
        border = "rounded",
        source = "if_many",
        format = function(raw)
          return raw.message
        end
      })
    end, opts) -- show documentation for what is under cursor

    opts.desc = "Restart LSP"
    keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary


    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, bufnr)
    end

    --
    -- Auto-format ("lint") on save.
    -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
    -- if not client:supports_method('textDocument/willSaveWaitUntil')
    --     and client:supports_method('textDocument/formatting') then
    --   print("Formatting on save")
    --   vim.api.nvim_create_autocmd('BufWritePre', {
    --     group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
    --     buffer = bufnr,
    --     callback = function()
    --       vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = 1000 })
    --     end,
    --   })
    -- end
  end
})
