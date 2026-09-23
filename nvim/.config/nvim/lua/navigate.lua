-- ctrl-hjkl navigation across nvim splits, the enclosing multiplexer (herdr or
-- tmux), and AeroSpace windows. Each layer hands off to the next at its edge.
local M = {}

local wincmd = { left = "h", down = "j", up = "k", right = "l" }
local tmux_flag = { left = "L", down = "D", up = "U", right = "R" }
local tmux_edge = { left = "left", down = "bottom", up = "top", right = "right" }

function M.aerospace(side)
  if vim.fn.executable("aerospace") == 1 then
    vim.system({ "aerospace", "focus", side })
  end
end

function M.move(side)
  -- herdr-splits owns nvim and herdr pane movement, and calls its at_edge
  -- handler (see plugins/herdr.lua) when both are exhausted.
  if vim.env.HERDR_ENV == "1" then
    return require("herdr-splits")["move_cursor_" .. side]()
  end

  local win = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. wincmd[side])
  if vim.api.nvim_get_current_win() ~= win then
    return
  end

  local pane = vim.env.TMUX_PANE
  if vim.env.TMUX and pane then
    local at_edge = vim.fn.system({ "tmux", "display-message", "-p", "-t", pane, "#{pane_at_" .. tmux_edge[side] .. "}" })
    if vim.trim(at_edge) == "0" then
      vim.fn.system({ "tmux", "select-pane", "-t", pane, "-" .. tmux_flag[side] })
      return
    end
  end

  M.aerospace(side)
end

return M
