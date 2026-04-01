function GetDefaultGitBranch()
  -- Check for a per-project override: git config project.primaryBranch <branch>
  local override_handle = io.popen("git config project.primaryBranch 2>/dev/null")
  if override_handle then
    local override = override_handle:read("*a"):gsub("%s+", "")
    override_handle:close()
    if override ~= "" then
      return override
    end
  end

  local handle = io.popen("git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'")
  if handle == nil then
    return "main"
  end
  local result = handle:read("*a"):gsub("%s+", "")
  handle:close()
  return result ~= "" and result or "main" -- fallback
end
