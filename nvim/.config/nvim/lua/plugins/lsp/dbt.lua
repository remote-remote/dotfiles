function OpenInDocSplit()
	local ext = vim.fn.expand("%:e")
	if ext ~= "sql" then
		return
	end

	local new_file = vim.fn.expand("%:r") .. ".yml"
	local found = false
	local word_under_cursor = vim.fn.expand("<cword>")

	for _, win in pairs(vim.api.nvim_list_wins()) do
		local status, doc_window = pcall(vim.api.nvim_win_get_var, win, "dbt_model_documentation")

		if status and doc_window then
			vim.api.nvim_set_current_win(win)
			vim.cmd("e " .. new_file)
			found = true
			break
		end
	end

	if not found then
		vim.cmd("vs " .. new_file)
		local new_win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_var(new_win, "dbt_model_documentation", 1)
	end

	local search_ok, _ = pcall(function()
		vim.cmd("/name: " .. word_under_cursor)
	end)
	if not search_ok then
		print("Not found: " .. word_under_cursor)
	end
end

function FindReferences()
	local filename = vim.fn.expand("%:t:r")
	local query = "ref('" .. filename .. "')"
	require("telescope.builtin").grep_string({ search = query })
end

return {
	"cfmeyers/dbt.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"rcarriga/nvim-notify",
	},
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "sql",
			callback = function()
				vim.bo.expandtab = true
				vim.bo.tabstop = 4
				vim.bo.shiftwidth = 4
				vim.keymap.set("n", "gd", ":DBTGoToDefinition<CR>", { buffer = true })
				vim.keymap.set("n", "gy", OpenInDocSplit)
				vim.keymap.set("n", "gr", FindReferences)
			end,
		})
	end,
}
