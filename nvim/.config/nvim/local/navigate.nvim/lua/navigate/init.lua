-- Moves focus and resizes across nested layers: nvim splits, then the
-- enclosing multiplexer (herdr, tmux or Rex), then AeroSpace windows. Each layer
-- hands off to the next at its edge.
--
-- The herdr-side half is bin/.local/bin/herdr-nav in ~/dotfiles. It forwards
-- ctrl-hjkl and alt-hjkl into nvim panes, so those chords are the contract
-- between the two halves.
local M = {}

local herdr = require("navigate.herdr")
local tmux = require("navigate.tmux")
local rex = require("navigate.rex")
local aerospace = require("navigate.aerospace")

local wincmd = { left = "h", down = "j", up = "k", right = "l" }

local NVIM_RESIZE_CELLS = 3

---@return table|nil backend with move(side) -> false at its outer edge
local function multiplexer()
  if herdr.in_session() then
    return herdr
  elseif tmux.in_session() then
    return tmux
  elseif rex.in_session() then
    -- Last: a herdr or tmux running inside Rex is the nearer layer.
    return rex
  end
end

function M.move(side)
  local win = vim.api.nvim_get_current_win()
  -- pcall: window commands raise E11 in the command-line window.
  if not pcall(vim.cmd, "wincmd " .. wincmd[side]) or vim.api.nvim_get_current_win() ~= win then
    return
  end
  local mux = multiplexer()
  if not (mux and mux.move(side)) then
    aerospace.move(side)
  end
end

local function has_neighbor(side)
  return vim.fn.winnr(wincmd[side]) ~= vim.fn.winnr()
end

---Moves the window border towards `side`. A window that spans its herdr pane
---on that axis, or a float, resizes the herdr pane instead. Under tmux,
---better-vim-tmux-resizer owns these keys (see plugins/navigate.lua).
function M.resize(side)
  local count = vim.v.count1
  local horizontal = side == "left" or side == "right"
  local floating = vim.api.nvim_win_get_config(0).relative ~= ""
  local spans = horizontal and not (has_neighbor("left") or has_neighbor("right"))
    or not horizontal and not (has_neighbor("up") or has_neighbor("down"))

  if floating or spans then
    if herdr.in_session() then
      herdr.resize(side, count)
    end
    return
  end

  -- Grow when the border being moved is this window's far (right/bottom) edge,
  -- which is the case exactly when a neighbour lies beyond it.
  local far = horizontal and "right" or "down"
  local grow = has_neighbor(far) == (side == far)
  vim.cmd((horizontal and "vertical resize " or "resize ") .. (grow and "+" or "-") .. NVIM_RESIZE_CELLS * count)
end

return M
