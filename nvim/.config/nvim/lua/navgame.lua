local M = {}

math.randomseed(os.time())

-- Persists for the lifetime of the Neovim session
local history = {
  rounds = 0,
  total_time = 0.0,
  total_keys = 0,
  best_time = nil,
  best_keys = nil,
}

local ns_target = vim.api.nvim_create_namespace("navgame_target")
local ns_keys = vim.api.nvim_create_namespace("navgame_keys")

local state = {
  buf = nil,
  win = nil,
  score_win = nil,
  target_row = nil,
  target_col = nil,
  win_width = nil,
  win_height = nil,
  start_time = nil,
  keycount = 0,
  phase = "idle", -- "preview" | "navigate" | "done" | "idle"
  timer = nil,
  autocmd_ids = {},
  filename = nil,
}

-- Read a random vertical slice from a random .lua file in the nvim config
local function get_random_chunk(height)
  local config = vim.fn.stdpath("config")
  local files = vim.fn.glob(config .. "/lua/**/*.lua", false, true)

  -- Keep only files with meaningful content
  local candidates = {}
  for _, f in ipairs(files) do
    local info = vim.uv.fs_stat(f)
    if info and info.size >= 400 then
      table.insert(candidates, f)
    end
  end

  if #candidates == 0 then
    return nil, nil
  end

  local path = candidates[math.random(#candidates)]
  local all = vim.fn.readfile(path)

  if #all <= height then
    return all, path
  end

  local start = math.random(1, #all - height + 1)
  local chunk = {}
  for i = start, start + height - 1 do
    chunk[#chunk + 1] = all[i]
  end
  return chunk, path
end

local function cleanup()
  state.phase = "idle"

  if state.timer then
    state.timer:stop()
    state.timer:close()
    state.timer = nil
  end

  vim.on_key(nil, ns_keys)

  for _, id in ipairs(state.autocmd_ids) do
    pcall(vim.api.nvim_del_autocmd, id)
  end
  state.autocmd_ids = {}

  if state.score_win and vim.api.nvim_win_is_valid(state.score_win) then
    vim.api.nvim_win_close(state.score_win, true)
  end
  state.score_win = nil

  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
  state.buf = nil
  state.target_row = nil
  state.target_col = nil
  state.win_width = nil
  state.win_height = nil
  state.start_time = nil
  state.keycount = 0
  state.filename = nil
end

local function show_score()
  if state.phase ~= "navigate" then return end
  state.phase = "done"
  vim.on_key(nil, ns_keys)

  local elapsed = (vim.uv.now() - state.start_time) / 1000
  local ks = state.keycount

  -- Record personal bests BEFORE updating history so we can flag improvements
  local pb_time = history.best_time ~= nil and elapsed < history.best_time
  local pb_keys = history.best_keys ~= nil and ks < history.best_keys

  history.rounds = history.rounds + 1
  history.total_time = history.total_time + elapsed
  history.total_keys = history.total_keys + ks
  history.best_time = math.min(history.best_time or elapsed, elapsed)
  history.best_keys = math.min(history.best_keys or ks, ks)

  local avg_time = history.total_time / history.rounds
  local avg_keys = history.total_keys / history.rounds

  local function maybe_pb(s, is_pb)
    return is_pb and (s .. "  ★ pb!") or s
  end

  local lines = {
    "",
    string.format("  Round #%d complete!", history.rounds),
    "",
    "  This round:",
    maybe_pb(string.format("  Time:       %.2fs", elapsed), pb_time),
    maybe_pb(string.format("  Keystrokes: %d", ks), pb_keys),
  }

  if history.rounds > 1 then
    table.insert(lines, "")
    table.insert(lines, string.format("  All-time (%d rounds):", history.rounds))
    table.insert(lines, string.format("  Avg time:   %.2fs", avg_time))
    table.insert(lines, string.format("  Avg keys:   %.1f", avg_keys))
    table.insert(lines, string.format("  Best time:  %.2fs", history.best_time))
    table.insert(lines, string.format("  Best keys:  %d", history.best_keys))
  end

  table.insert(lines, "")
  table.insert(lines, "  [r] next round  [q] quit")
  table.insert(lines, "")

  local w = 0
  for _, l in ipairs(lines) do
    w = math.max(w, #l)
  end
  w = w + 2 -- padding

  local score_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(score_buf, 0, -1, false, lines)
  vim.bo[score_buf].modifiable = false

  local score_win = vim.api.nvim_open_win(score_buf, true, {
    relative = "editor",
    width = w,
    height = #lines,
    row = math.floor((vim.o.lines - #lines) / 2),
    col = math.floor((vim.o.columns - w) / 2),
    style = "minimal",
    border = "rounded",
    title = " NavGame ",
    title_pos = "center",
  })
  state.score_win = score_win

  local function close_score()
    if vim.api.nvim_win_is_valid(score_win) then
      vim.api.nvim_win_close(score_win, true)
    end
    state.score_win = nil
  end

  vim.keymap.set("n", "q", function()
    close_score(); cleanup()
  end, { buffer = score_buf, nowait = true })
  vim.keymap.set("n", "<Esc>", function()
    close_score(); cleanup()
  end, { buffer = score_buf, nowait = true })
  vim.keymap.set("n", "r", function()
    close_score(); cleanup(); M.start()
  end, { buffer = score_buf, nowait = true })
end

local function start_navigation(buf, win)
  state.phase = "navigate"
  state.start_time = vim.uv.now()
  state.keycount = 0

  vim.on_key(function()
    if state.phase == "navigate" then
      state.keycount = state.keycount + 1
    end
  end, ns_keys)

  local cursor_id = vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = buf,
    callback = function()
      if state.phase ~= "navigate" then return end
      local pos = vim.api.nvim_win_get_cursor(win)
      -- pos[1] is 1-indexed row, pos[2] is 0-indexed byte col
      if pos[1] - 1 == state.target_row and pos[2] == state.target_col then
        show_score()
      end
    end,
  })
  table.insert(state.autocmd_ids, cursor_id)

  vim.keymap.set("n", "q", cleanup, { buffer = buf, nowait = true })
  vim.keymap.set("n", "<Esc>", cleanup, { buffer = buf, nowait = true })
end

function M.start()
  cleanup()

  -- Window fills most of the screen
  local width = math.min(vim.o.columns - 4, 120)
  local height = math.min(vim.o.lines - 6, 40)

  local lines, path = get_random_chunk(height)
  if not lines or #lines == 0 then
    vim.notify("NavGame: no source files found in " .. vim.fn.stdpath("config"), vim.log.levels.ERROR)
    return
  end

  -- Retry if the chunk has no valid (non-whitespace) targets
  local has_target = false
  for _, line in ipairs(lines) do
    if line:match("%S") then
      has_target = true
      break
    end
  end
  if not has_target then
    return M.start()
  end

  local short_name = path and vim.fn.fnamemodify(path, ":~:.") or "?"
  state.filename = short_name

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Apply filetype for syntax highlighting before locking the buffer
  if path then
    local ext = path:match("%.(%w+)$")
    if ext then
      vim.bo[buf].filetype = ext
    end
  end
  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " NavGame: " .. short_name .. " ",
    title_pos = "left",
  })
  vim.wo[win].wrap = false

  state.buf = buf
  state.win = win
  state.win_width = width
  state.win_height = height

  -- Only consider targets within the visible column range
  local valid = {}
  for r, line in ipairs(lines) do
    for c = 1, math.min(#line, width) do
      if line:sub(c, c):match("%S") then
        table.insert(valid, { r - 1, c - 1 }) -- 0-indexed
      end
    end
  end

  local target = valid[math.random(#valid)]
  state.target_row = target[1]
  state.target_col = target[2]

  -- Start cursor at the vertically opposite end from the target
  local start_row = state.target_row < math.floor(#lines / 2) and #lines or 1
  vim.api.nvim_win_set_cursor(win, { start_row, 0 })

  -- Flash the target for 1 second
  state.phase = "preview"
  vim.api.nvim_buf_set_extmark(buf, ns_target, state.target_row, state.target_col, {
    hl_group = "IncSearch",
    end_col = state.target_col + 1,
  })

  local timer = vim.uv.new_timer()
  state.timer = timer
  timer:start(1000, 0, vim.schedule_wrap(function()
    if not state.timer then return end
    state.timer:stop()
    state.timer:close()
    state.timer = nil
    if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then return end
    vim.api.nvim_buf_clear_namespace(buf, ns_target, 0, -1)
    if state.phase == "preview" then
      start_navigation(buf, win)
    end
  end))

  -- Tear down if the window is force-closed
  local close_id = vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    once = true,
    callback = cleanup,
  })
  table.insert(state.autocmd_ids, close_id)
end

vim.api.nvim_create_user_command("NavGame", function()
  M.start()
end, {})

-- Expose history for external inspection (e.g. statusline)
M.history = history

return M
