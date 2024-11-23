-- Get the path of the current buffer relative to the git root
local function get_relative_path()
	local filepath = vim.fn.expand("%")
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if git_root == "" then
		print("Not inside a Git repository.")
		return nil
	end
	local relative_path = vim.fn.fnamemodify(filepath, ":." .. git_root)
	return relative_path
end

-- Get the current commit hash
local function get_commit_hash()
	local commit_hash = vim.fn.systemlist("git rev-parse HEAD")[1]
	if commit_hash == "" then
		print("Unable to get commit hash.")
		return nil
	end
	return commit_hash
end

-- Get the remote URL and transform it to HTTPS format
local function get_remote_url()
	local remote_url = vim.fn.systemlist("git config --get remote.origin.url")[1]
	if remote_url == "" then
		print("No remote repository found.")
		return nil
	end
	-- Transform SSH URL to HTTPS
	if remote_url:find("https://") then
		return remote_url
	end
	local colon_index = remote_url:find(":")
	remote_url = "https://github.com/" .. remote_url:sub(colon_index + 1)
	remote_url = remote_url:gsub("%.git$", "")
	return remote_url
end

-- Get the line number range if visual mode
local function get_line_range(range_start, range_end)
	if range_start and range_end and range_start ~= range_end then
		return "#L" .. range_start .. "-L" .. range_end
	elseif range_start then
		return "#L" .. range_start
	end
	return ""
end

-- Function to generate GitHub permalink
local function GitPermalink(range_start, range_end)
	local relative_path = get_relative_path()
	local commit_hash = get_commit_hash()
	local remote_url = get_remote_url()
	local line_range = get_line_range(range_start, range_end)

	if not (relative_path and commit_hash and remote_url) then
		return
	end

	-- Build the permalink
	local permalink = string.format("%s/blob/%s/%s%s", remote_url, commit_hash, relative_path, line_range)

	-- Copy the permalink to the clipboard
	vim.fn.setreg("+", permalink)
	print("GitHub permalink copied to clipboard:")
	print(permalink)
end

local function GitMainLink(range_start, range_end)
	local relative_path = get_relative_path()
	local remote_url = get_remote_url()
	local line_range = get_line_range(range_start, range_end)

	if not (relative_path and remote_url) then
		return
	end

	-- Build the permalink
	local permalink = string.format("%s/blob/main/%s%s", remote_url, relative_path, line_range)

	-- Copy the permalink to the clipboard
	vim.fn.setreg("+", permalink)
	print("GitHub link to file in main copied:")
	print(permalink)
end

-- Register the command as GitPermalink
vim.api.nvim_create_user_command("GitPermalink", function(opts)
	GitPermalink(opts.line1, opts.line2)
end, { range = true })
vim.api.nvim_create_user_command("GitMainLink", function(opts)
	GitMainLink(opts.line1, opts.line2)
end, { range = true })
