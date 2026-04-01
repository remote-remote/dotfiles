return {
  "nanozuki/tabby.nvim",
  config = function()
    vim.opt.sessionoptions:append("globals")
    require("tabby").setup({
      preset = "tab_only",
    })
  end,
}
