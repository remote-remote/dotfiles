vim.o.tabstop = 2
vim.o.shiftwidth = 2

vim.o.expandtab = true
vim.o.softtabstop = 2

vim.o.foldlevel = 12
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"

vim.o.scrolloff = 15

vim.o.clipboard = "unnamedplus"

vim.wo.number = true
vim.wo.relativenumber = true

vim.o.undofile = true

vim.o.listchars = "eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣"

vim.opt.termguicolors = true
vim.cmd.colorscheme("kanagawa-paper")

vim.filetype.add({
	extension = {
		http = "http",
		jbuilder = "ruby",
	},
})
