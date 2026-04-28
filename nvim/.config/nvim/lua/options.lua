vim.o.tabstop = 2
vim.o.shiftwidth = 2

-- come back to the preview later
vim.o.completeopt = "menu,noinsert,noselect"

vim.keymap.set("i", "<CR>", function()
	if vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected ~= -1 then
		return "<C-y>"
	end
	return "<CR>"
end, { expr = true })

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
vim.cmd.colorscheme("vague")

vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local line_count = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= line_count then
			vim.api.nvim_win_set_cursor(0, mark)
		end
	end,
})

local function cycle_colorscheme(direction)
	local all = vim.fn.getcompletion("", "color")
	local current = vim.g.colors_name or ""
	local idx = 1
	for i, name in ipairs(all) do
		if name == current then
			idx = i
			break
		end
	end
	idx = ((idx - 1 + direction) % #all) + 1
	vim.cmd.colorscheme(all[idx])
	vim.notify(all[idx])
end

vim.api.nvim_create_user_command("NextColorscheme", function() cycle_colorscheme(1) end, {})
vim.api.nvim_create_user_command("PrevColorscheme", function() cycle_colorscheme(-1) end, {})

vim.filetype.add({
	extension = {
		http = "http",
		jbuilder = "ruby",
	},
})
