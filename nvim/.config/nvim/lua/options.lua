vim.o.tabstop = 2
vim.o.shiftwidth = 2

-- come back to the preview later
vim.o.completeopt = "menu,noinsert,noselect"

vim.o.expandtab = true
vim.o.softtabstop = 2

vim.o.foldlevel = 99
vim.o.foldlevelstart = 99

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})

vim.o.scrolloff = 15

vim.o.clipboard = "unnamedplus"

vim.wo.number = true
vim.wo.relativenumber = true

vim.o.undofile = true

vim.o.listchars = "eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣"

vim.opt.termguicolors = true
vim.cmd.colorscheme("kanagawa-dragon")

vim.filetype.add({
  extension = {
    http = "http",
    jbuilder = "ruby",
  },
})
