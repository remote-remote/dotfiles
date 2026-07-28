local eslint_bin = vim.fn.exepath("vscode-eslint-language-server")
if eslint_bin == "" then return {} end

return {
  cmd = { "node", "--max-old-space-size=8192", eslint_bin, "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
  root_markers = { "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs", ".eslintrc", ".eslintrc.js", ".eslintrc.json", ".eslintrc.yml", ".git" },
  on_init = function(client)
    local root = client.root_dir
    if root and vim.startswith(root, "/") then
      client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
        workingDirectory = { directory = root },
      })
    end
  end,
  settings = {
    validate = "on",
    packageManager = nil,
    useESLintClass = false,
    experimental = {
      useFlatConfig = nil, -- auto-detect
    },
    codeActionOnSave = {
      enable = false,
      mode = "all",
    },
    format = true,
    quiet = false,
    onIgnoredFiles = "off",
    rulesCustomizations = {},
    run = "onType",
    problems = {
      shortenToSingleLine = false,
    },
    nodePath = "",
    codeAction = {
      disableRuleComment = {
        enable = true,
        location = "separateLine",
      },
      showDocumentation = {
        enable = true,
      },
    },
  },
  handlers = {
    ["eslint/openDoc"] = function(_, result)
      if result then
        vim.ui.open(result.url)
      end
      return {}
    end,
    ["eslint/confirmESLintExecution"] = function(_, result)
      if not result then
        return
      end
      return 4 -- approved
    end,
    ["eslint/probeFailed"] = function()
      vim.notify("[lsp] ESLint probe failed.", vim.log.levels.WARN)
      return {}
    end,
    ["eslint/noLibrary"] = function()
      vim.notify("[lsp] Unable to find ESLint library.", vim.log.levels.WARN)
      return {}
    end,
  },
}
