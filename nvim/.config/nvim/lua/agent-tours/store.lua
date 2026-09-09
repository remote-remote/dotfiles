-- On-disk format, root matching, the watcher, and cursor write-back.
-- The only module that knows JSON exists.
local M = {}

M.SUBDIR = ".agent/tours"

local self_writes = {}
local watcher = { handle = nil, timer = nil, pending = {}, blind = false }

local function realpath(p)
  if type(p) ~= "string" or p == "" then return nil end
  return vim.uv.fs_realpath(p) or p
end

local function slurp(path)
  local fd = io.open(path, "r")
  if not fd then return nil end
  local raw = fd:read("*a")
  fd:close()
  return raw
end

local function spit(path, raw)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local fd, err = io.open(path, "w")
  if not fd then return false, err end
  fd:write(raw)
  fd:close()
  return true
end

M.realpath = realpath

function M.repo_root(start)
  start = start or vim.uv.cwd()
  local marker = vim.fs.root(start, ".git")
  return realpath(marker or start)
end

function M.tours_dir(root)
  return (root or M.repo_root()) .. "/" .. M.SUBDIR
end

function M.validate(data)
  if type(data) ~= "table" then return "not a json object" end
  if data.version ~= 1 then return "unsupported version: " .. tostring(data.version) end
  if type(data.root) ~= "string" then return "missing root" end
  if type(data.steps) ~= "table" or #data.steps == 0 then return "no steps" end
  for i, step in ipairs(data.steps) do
    if type(step.path) ~= "string" then return ("step %d: missing path"):format(i) end
    if type(step.range) ~= "table" or type(step.range[1]) ~= "number" then
      return ("step %d: range must be [start, end]"):format(i)
    end
    if type(step.note) ~= "string" then return ("step %d: missing note"):format(i) end
  end
  return nil
end

function M.decode(raw, path)
  local ok, data = pcall(vim.json.decode, raw, { luanil = { object = true, array = true } })
  if not ok then return nil, "invalid json: " .. tostring(data) end
  local err = M.validate(data)
  if err then return nil, err end
  data.__file = path
  return data
end

function M.read(path)
  local raw = slurp(path)
  if not raw then return nil, "cannot read " .. path end
  return M.decode(raw, path)
end

-- Returns tours whose `root` resolves to `root`, plus a list of {path, err}
-- for files that failed to parse so a typo is visible rather than silent.
function M.list(root)
  root = root or M.repo_root()
  local dir = M.tours_dir(root)
  local tours, errors = {}, {}
  if not vim.uv.fs_stat(dir) then return tours, errors end
  for name, kind in vim.fs.dir(dir) do
    if kind == "file" and name:match("%.json$") then
      local path = dir .. "/" .. name
      local data, err = M.read(path)
      if data then
        if realpath(data.root) == root then table.insert(tours, data) end
      else
        table.insert(errors, { path = path, err = err })
      end
    end
  end
  table.sort(tours, function(a, b)
    return (a.title or a.id or a.__file) < (b.title or b.id or b.__file)
  end)
  return tours, errors
end

-- Rewrites `cursor` in the raw text instead of re-encoding, so a hand-authored
-- tour keeps its formatting, key order and comments-in-prose intact. The patch
-- is decoded and diffed against the original before it is trusted: a note
-- containing the literal text `"cursor": 3` would otherwise be a plausible
-- mis-target for the pattern.
function M.patch_cursor(raw, index)
  local ok, before = pcall(vim.json.decode, raw, { luanil = { object = true, array = true } })
  if not ok then return nil, "invalid json" end
  before.__file = nil

  local candidates = {}
  local from = 1
  while true do
    local s, e, prefix = raw:find('("cursor"%s*:%s*)%-?%d+', from)
    if not s then break end
    table.insert(candidates, raw:sub(1, s - 1) .. prefix .. tostring(index) .. raw:sub(e + 1))
    from = e + 1
  end
  local inserted, n = raw:gsub("^(%s*{)", '%1\n  "cursor": ' .. tostring(index) .. ",", 1)
  if n == 1 then table.insert(candidates, inserted) end

  for _, candidate in ipairs(candidates) do
    local decoded_ok, after = pcall(vim.json.decode, candidate, { luanil = { object = true, array = true } })
    if decoded_ok and after.cursor == index then
      after.cursor = before.cursor
      if vim.deep_equal(before, after) then return candidate end
    end
  end

  before.cursor = index
  return vim.json.encode(before)
end

function M.write_cursor(data, index)
  local path = data and data.__file
  if not path then return false, "tour is not backed by a file" end
  local raw = slurp(path)
  if not raw then return false, "cannot read " .. path end
  local patched, err = M.patch_cursor(raw, index)
  if not patched then return false, err end
  data.cursor = index
  if patched == raw then return true end
  local ok, werr = spit(path, patched)
  if not ok then return false, werr end
  self_writes[path] = patched
  return true
end

local function drain(cb)
  local paths = vim.tbl_keys(watcher.pending)
  local blind = watcher.blind
  watcher.pending, watcher.blind = {}, false

  local external = false
  if blind and #paths == 0 then
    -- Platform gave us no filename. Consume one pending echo, otherwise assume
    -- the change was somebody else's.
    external = true
    for path, content in pairs(self_writes) do
      if slurp(path) == content then
        self_writes[path] = nil
        external = false
        break
      end
    end
  end
  for _, path in ipairs(paths) do
    if self_writes[path] and slurp(path) == self_writes[path] then
      self_writes[path] = nil
    else
      external = true
    end
  end
  if external then cb() end
end

-- fs_event fires several times for one save (editors write a temp file and
-- rename over the target), so the debounce is not optional: without it a single
-- write re-renders the tour three times.
function M.watch(root, cb)
  M.unwatch()
  local dir = M.tours_dir(root)
  if not vim.uv.fs_stat(dir) then return false end
  local handle = vim.uv.new_fs_event()
  local timer = vim.uv.new_timer()
  if not handle or not timer then return false end
  watcher.handle, watcher.timer = handle, timer

  local ok = pcall(handle.start, handle, dir, {}, function(err, filename)
    if err then return end
    if filename then
      watcher.pending[dir .. "/" .. filename] = true
    else
      watcher.blind = true
    end
    timer:stop()
    timer:start(120, 0, function()
      vim.schedule(function() drain(cb) end)
    end)
  end)
  if not ok then
    M.unwatch()
    return false
  end
  return true
end

function M.unwatch()
  if watcher.timer then
    watcher.timer:stop()
    watcher.timer:close()
  end
  if watcher.handle then
    watcher.handle:stop()
    watcher.handle:close()
  end
  watcher = { handle = nil, timer = nil, pending = {}, blind = false }
end

function M.abs_path(data, step)
  if step.path:sub(1, 1) == "/" then return step.path end
  return data.root .. "/" .. step.path
end

return M
