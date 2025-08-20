local tsserver_filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact' }
local ts_ls_config = {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = tsserver_filetypes,
  root_markers = { "package.json", ".git" }
}

-- Check for npm-installed @vue/language-server
local npm_vue_path = vim.fn.system('npm root -g'):gsub('\n', '') .. '/@vue/language-server'


if vim.fn.isdirectory(npm_vue_path) == 1 then
  local vue_plugin = {
    name = '@vue/typescript-plugin',
    location = npm_vue_path,
    languages = { 'vue' },
  }

  ts_ls_config.init_options = {
    plugins = { vue_plugin },
  }

  -- Add vue to filetypes
  local vue_filetypes = table.insert(tsserver_filetypes, 'vue')
  ts_ls_config.filetypes = vue_filetypes
end

return ts_ls_config
