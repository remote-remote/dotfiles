local store = require("agent-tours.store")
local anchor = require("agent-tours.anchor")
local tour = require("agent-tours.tour")
local format = require("agent-tours.format")
local render = require("agent-tours.render")
local view = require("agent-tours.view")

local M = {}

-- Seam for the herdr focus adapter (later slice). Courtesy only: raising the
-- editor pane must never be load-bearing, so the no-op is a complete
-- implementation as far as the rest of the plugin is concerned.
M.focus = {
  is_available = function() return false end,
  reveal = function() end,
}

local state = { root = nil, resolved = {} }

local function notify(msg, level)
  vim.notify("[agent-tours] " .. msg, level or vim.log.levels.INFO)
end

local function abs_path(step)
  return store.abs_path(tour.data(), step)
end

local function forget_anchors()
  for _, result in pairs(state.resolved) do anchor.forget(result) end
  state.resolved = {}
end

local function resolve(index, step)
  local cached = state.resolved[index]
  if cached then
    local live = anchor.track(cached)
    if live then
      return vim.tbl_extend("force", cached, live)
    end
  end
  local file = abs_path(step)
  if not vim.uv.fs_stat(file) then
    return { status = "broken", rung = "no_match", start_line = step.range[1], end_line = step.range[1] }
  end
  local bufnr = vim.fn.bufadd(file)
  vim.fn.bufload(bufnr)
  local result = anchor.resolve(bufnr, step)
  state.resolved[index] = result
  return result
end

-- Every step, resolved. The panel's line numbers come from the live extmarks,
-- not from the JSON, so editing the file under a tour keeps the index honest.
local function entries()
  local out = {}
  for i, step in ipairs(tour.data().steps) do
    local result = resolve(i - 1, step)
    table.insert(out, {
      index = i - 1,
      step = step,
      line = result.start_line or step.range[1],
      status = result.status,
    })
  end
  return out
end

function M.show(opts)
  opts = opts or {}
  if not tour.is_active() then return end
  local index = tour.index()
  local step = tour.current()
  if not step then return end

  local result = resolve(index, step)
  local detail = anchor.RUNG_LABEL[result.rung]
  if result.status == "exact" then detail = nil end
  local data = tour.data()

  view.show({
    keep_cursor = opts.keep_cursor,
    code = {
      file = abs_path(step),
      note = step.note,
      status = result.status,
      detail = detail,
      start_line = result.start_line or step.range[1],
      end_line = result.end_line or step.range[2] or step.range[1],
    },
    panel = {
      title = data.title or data.id or "tour",
      index = index,
      total = tour.count(),
      entries = entries(),
    },
  })

  local ok, err = store.write_cursor(data, index)
  if not ok then notify("could not write cursor: " .. tostring(err), vim.log.levels.WARN) end
  if M.focus.is_available() then M.focus.reveal() end
end

function M.start(data)
  forget_anchors()
  tour.load(data)
  M.show()
end

function M.open(name)
  state.root = state.root or store.repo_root()
  local tours, errors = store.list(state.root)
  for _, e in ipairs(errors) do
    notify(("skipped %s: %s"):format(vim.fs.basename(e.path), e.err), vim.log.levels.WARN)
  end
  if #tours == 0 then
    notify("no tours for " .. state.root .. " in " .. store.tours_dir(state.root), vim.log.levels.WARN)
    return
  end
  if name and name ~= "" then
    for _, t in ipairs(tours) do
      if t.id == name then return M.start(t) end
    end
    notify("no tour with id " .. name, vim.log.levels.WARN)
    return
  end
  if #tours == 1 then return M.start(tours[1]) end
  vim.ui.select(tours, {
    prompt = "Tour",
    format_item = function(t)
      return ("%s  (%d steps)"):format(t.title or t.id, #t.steps)
    end,
  }, function(choice)
    if choice then M.start(choice) end
  end)
end

-- The teardown half of quit, without touching the windows: `view` calls this
-- when the tab or one of its windows is closed behind our back.
local function discard()
  forget_anchors()
  tour.unload()
end

function M.quit()
  view.close()
  discard()
end

function M.next()
  if not tour.is_active() then return M.open() end
  if not tour.next() then
    notify("end of tour")
    return
  end
  M.show()
end

function M.prev()
  if not tour.is_active() then return end
  if not tour.prev() then
    notify("start of tour")
    return
  end
  M.show()
end

function M.jump(index)
  if not tour.is_active() then return end
  if tour.jump(index) then M.show() end
end

-- What <CR> in the panel means: show the step and hand the reader the code.
function M.select(index)
  M.jump(index)
  view.focus_code()
end

function M.steps()
  if not tour.is_active() then
    notify("no active tour", vim.log.levels.WARN)
    return
  end
  local items = entries()
  vim.ui.select(items, {
    prompt = tour.data().title or "Steps",
    format_item = function(item)
      return ("%d. %s  %s:%d"):format(
        item.index + 1, format.step_title(item.step, 60), item.step.path, item.line
      )
    end,
  }, function(choice)
    if choice then M.jump(choice.index) end
  end)
end

-- The escape hatch. From inside the tour tab it closes the tour first: :cnext
-- has to be free to reuse windows, and the panel is not a window it may have.
function M.to_quickfix()
  if not tour.is_active() then
    notify("no active tour", vim.log.levels.WARN)
    return
  end
  local data = tour.data()
  local items = {}
  for _, e in ipairs(entries()) do
    table.insert(items, {
      filename = abs_path(e.step),
      lnum = e.line,
      col = 1,
      text = ("%d/%d  %s  %s"):format(
        e.index + 1, #data.steps, format.step_title(e.step, 60), (e.step.note:gsub("%s+", " "))
      ),
    })
  end
  local title = data.title or data.id or "agent-tour"

  if view.is_current() then M.quit() end
  vim.fn.setqflist({}, " ", { title = title, items = items })
  vim.cmd("copen")
end

local function on_disk_change()
  if not tour.is_active() then return end
  local file = tour.data().__file
  local data, err = store.read(file)
  if not data then
    notify("tour reload failed: " .. tostring(err), vim.log.levels.WARN)
    return
  end
  forget_anchors()
  tour.load(data)
  M.show({ keep_cursor = true })
end

function M.setup(opts)
  opts = opts or {}
  render.setup()
  view.on_close = discard
  state.root = opts.root or store.repo_root()
  store.watch(state.root, on_disk_change)

  local cmd = vim.api.nvim_create_user_command
  cmd("AgentTour", function(a) M.open(a.args) end, { nargs = "?", desc = "Open an agent tour" })
  cmd("AgentTourQuit", M.quit, { desc = "Leave the active tour" })
  cmd("AgentTourNext", M.next, { desc = "Next tour step" })
  cmd("AgentTourPrev", M.prev, { desc = "Previous tour step" })
  cmd("AgentTourSteps", M.steps, { desc = "Pick a step in the active tour" })
  cmd("AgentTourQuickfix", M.to_quickfix, { desc = "Dump the active tour into quickfix" })
end

return M
