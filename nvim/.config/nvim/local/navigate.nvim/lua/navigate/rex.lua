-- Rex backend. Calls the pane_focus_direction action defined in
-- ~/.config/rex/init.lua, which focuses without wrapping and reports whether
-- focus moved. rex resolves the session from $REX_BLOCK.
local M = {}

local TIMEOUT_MS = 500

function M.in_session()
  return (vim.env.REX_BLOCK or "") ~= "" and vim.fn.executable("rex") == 1
end

---Focuses the neighbouring Rex pane. Returns false only at the outer edge; a
---failed call notifies and stops the handoff.
function M.move(side)
  local r = vim.system({ "rex", "do", "pane_focus_direction", "direction=" .. side }, { text = true }):wait(TIMEOUT_MS)
  if r.code ~= 0 then
    vim.notify(("rex pane_focus_direction failed: %s"):format(vim.trim(r.stderr or "")), vim.log.levels.WARN)
    return true
  end
  local ok, result = pcall(vim.json.decode, r.stdout)
  return not (ok and type(result) == "table" and result.moved == false)
end

return M
