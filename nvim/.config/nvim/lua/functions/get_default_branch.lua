function GetDefaultGitBranch()
  local handle = io.popen("git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'")
  if handle == nil then
    return "main"
  end
  local result = handle:read("*a"):gsub("%s+", "")
  handle:close()
  return result ~= "" and result or "main" -- fallback
end
