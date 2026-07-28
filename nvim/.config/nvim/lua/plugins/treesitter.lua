return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local ts = require("nvim-treesitter")

      -- Parsers to install up front (main branch installs asynchronously)
      ts.install({
        "bash",
        "c",
        "csv",
        "diff",
        "dockerfile",
        "git_rebase",
        "gitcommit",
        "gitignore",
        "hcl",
        "html",
        "ini",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "mermaid",
        "nix",
        "python",
        "query",
        "rust",
        "sql",
        "ssh_config",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      })

      vim.treesitter.language.register("markdown", { "livebook" })
      -- main branch dropped the jsonc grammar; json parser handles it fine
      vim.treesitter.language.register("json", { "jsonc" })

      -- Enable highlighting and indentation per buffer; auto-install missing parsers
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          -- get_lang() falls back to the filetype itself, so filter against the
          -- parser registry to avoid install warnings for qf, calltree, etc.
          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          if not lang or not vim.tbl_contains(ts.get_available(), lang) then
            return
          end

          local function start()
            local ok = pcall(vim.treesitter.start, args.buf, lang)
            if ok then
              vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
            return ok
          end

          if not start() then
            ts.install(lang):await(function(err)
              if not err and vim.api.nvim_buf_is_valid(args.buf) then
                start()
              end
            end)
          end
        end,
      })
    end,
  },
}
