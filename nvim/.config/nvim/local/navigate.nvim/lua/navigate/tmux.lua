-- tmux backend.
local M = {}

local select_flag = { left = "L", down = "D", up = "U", right = "R" }
local edge_name = { left = "left", down = "bottom", up = "top", right = "right" }

function M.in_session()
  return vim.env.TMUX ~= nil and vim.env.TMUX_PANE ~= nil
end

---Selects the neighbouring tmux pane. Returns false at the outer edge.
function M.move(side)
  local pane = vim.env.TMUX_PANE
  local at_edge = vim.fn.system({ "tmux", "display-message", "-p", "-t", pane, "#{pane_at_" .. edge_name[side] .. "}" })
  if vim.trim(at_edge) ~= "0" then
    return false
  end
  vim.fn.system({ "tmux", "select-pane", "-t", pane, "-" .. select_flag[side] })
  return true
end

return M
