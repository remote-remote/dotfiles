function open_test_file()
	local current_file = vim.fn.expand("%:.")
	local test_file

	-- Handle lib/ and app/ files
	if current_file:match("^[al][pi][pb]/.+.rb$") then
		print("not a test")
		local path_without_prefix = current_file:gsub("^[al][pi][pb]/", "")
		print("path without prefix:", path_without_prefix)

		test_file = "test/" .. path_without_prefix:gsub("%.rb$", "_test.rb")
		print("test_file", test_file)
	-- Handle test files (switch back to implementation)
	elseif current_file:match("^test/.+_test%.rb$") then
		local path_without_prefix = current_file:gsub("^test/", "")
		-- Try app/ first, then lib/
		local impl_file = "app/" .. path_without_prefix:gsub("_test%.rb$", ".rb")
		if vim.fn.filereadable(impl_file) == 1 then
			test_file = impl_file
		else
			test_file = "lib/" .. path_without_prefix:gsub("_test%.rb$", ".rb")
		end
	else
		print("didn't match anything")
	end

	if test_file then
		vim.cmd("tabnew " .. test_file)
	else
		print("Could not locate test file")
	end
end

vim.keymap.set("n", "<leader>rt", open_test_file, { noremap = true, silent = true })
