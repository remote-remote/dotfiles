local vue_cmd = "vue-language-server"

return {
  cmd = { vue_cmd, "--stdio" },
  filetypes = { "vue" },
  root_markers = { "package.json", ".git" }
}
