-- AeroSpace backend: the outermost layer, so it never hands off further.
local M = {}

function M.move(side)
  if vim.fn.executable("aerospace") == 1 then
    vim.system({ "aerospace", "focus", side })
  end
end

return M
