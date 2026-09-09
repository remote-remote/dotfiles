-- The tour index: a nofile buffer listing every step with its live line and
-- anchor status. Knows nothing about the code window; it draws a spec and maps
-- keys back to the plugin.
local format = require("agent-tours.format")

local M = {}

M.ns = vim.api.nvim_create_namespace("agent-tours-panel")
M.FILETYPE = "agent-tour-panel"
M.WIDTH = 38

M.WINOPTS = {
  number = false,
  relativenumber = false,
  signcolumn = "no",
  foldcolumn = "0",
  foldenable = false,
  foldmethod = "manual",
  wrap = false,
  list = false,
  spell = false,
  cursorline = true,
  winfixwidth = true,
  colorcolumn = "",
  -- The config sets scrolloff=15 globally, which in a 38-column panel would
  -- scroll the list on every j.
  scrolloff = 0,
  sidescrolloff = 0,
  fillchars = "eob: ",
  statusline = " tour",
  -- A fresh split inherits whatever winbar the window it came from had, and
  -- lspsaga's breadcrumb keeps setting one; the panel is not a code window.
  winbar = "",
}

local state = { bufnr = nil, rows = {} }

local function tour()
  return require("agent-tours")
end

local function map(buf, lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { buffer = buf, nowait = true, silent = true, desc = desc })
end

function M.step_at(lnum)
  return state.rows[lnum]
end

local function keymaps(buf)
  local function under_cursor()
    return M.step_at(vim.api.nvim_win_get_cursor(0)[1])
  end
  map(buf, "<CR>", function()
    local i = under_cursor()
    if i then tour().select(i) end
  end, "Tour: go to step")
  map(buf, "o", function()
    local i = under_cursor()
    if i then tour().jump(i) end
  end, "Tour: show step, stay in panel")
  map(buf, "]t", function() tour().next() end, "Tour: next step")
  map(buf, "[t", function() tour().prev() end, "Tour: previous step")
  map(buf, "q", function() tour().quit() end, "Tour: quit")
  map(buf, "Q", function() tour().to_quickfix() end, "Tour: dump to quickfix")
end

function M.buf()
  if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then return state.bufnr end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modeline = false
  vim.bo[buf].undolevels = -1
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = M.FILETYPE
  -- The name is what a tabline shows for this tab, so it says what the tab is
  -- rather than which of its two buffers happens to be focused.
  pcall(vim.api.nvim_buf_set_name, buf, "agent-tour://tour")
  state.bufnr = buf
  keymaps(buf)
  return buf
end

-- Only recenter when the target has fallen out of view, so a short tour keeps
-- its list pinned to the top instead of floating in the middle of the window.
local function reveal(win, lnum)
  vim.api.nvim_win_call(win, function()
    if lnum < vim.fn.line("w0") or lnum > vim.fn.line("w$") then
      vim.cmd("normal! zz")
    end
  end)
end

-- `keep_cursor` is what the file watcher wants: a redraw that leaves the reader
-- where they were browsing instead of yanking the cursor to the current step.
function M.draw(win, spec, keep_cursor)
  local buf = M.buf()
  local width = vim.api.nvim_win_get_width(win)
  local built = format.panel(spec, width)
  state.rows = built.rows

  local saved
  if keep_cursor and vim.api.nvim_win_get_buf(win) == buf then
    saved = vim.api.nvim_win_get_cursor(win)[1]
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, built.lines)
  vim.bo[buf].modifiable = false

  vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
  for _, m in ipairs(built.marks) do
    local row, col, end_col, hl = m[1], m[2], m[3], m[4]
    local len = #built.lines[row + 1]
    end_col = math.min(end_col, len)
    if col < end_col then
      pcall(vim.api.nvim_buf_set_extmark, buf, M.ns, row, col, { end_col = end_col, hl_group = hl })
    end
  end

  local target = math.max(1, math.min(saved or built.current_row or 1, #built.lines))
  vim.api.nvim_win_set_cursor(win, { target, 0 })
  reveal(win, target)
end

function M.clear()
  state.rows = {}
  if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
    vim.bo[state.bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, {})
    vim.bo[state.bufnr].modifiable = false
    vim.api.nvim_buf_clear_namespace(state.bufnr, M.ns, 0, -1)
  end
end

return M
