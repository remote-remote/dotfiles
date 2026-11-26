-- herdr backend. Talks to the herdr server socket instead of running the herdr
-- CLI: endpoint security makes each herdr exec cost ~25 ms, a socket request
-- <1 ms. Uses pane.edges, pane.zoom, pane.focus_direction and pane.resize.
local M = {}

local TIMEOUT_MS = 200
local RESIZE_RATIO = 0.03

function M.in_session()
  return vim.env.HERDR_ENV == "1" and (vim.env.HERDR_PANE_ID or "") ~= ""
end

local function socket_path()
  return vim.env.HERDR_SOCKET_PATH or (vim.env.HOME .. "/.config/herdr/herdr.sock")
end

---Sends one request about this nvim's pane and returns the reply's `result`
---table, or nil after notifying. The server replies with a single JSON line
---and closes, so every request connects afresh.
---@param method string e.g. "pane.edges"
---@param params? table pane_id defaults to $HERDR_PANE_ID
---@return table|nil
function M.call(method, params)
  params = params or {}
  params.pane_id = params.pane_id or vim.env.HERDR_PANE_ID
  local payload = vim.json.encode({ id = "nvim", method = method, params = params }) .. "\n"

  local pipe = vim.uv.new_pipe(false)
  if not pipe then
    return nil
  end
  local chunks, err, done = {}, nil, false
  pipe:connect(socket_path(), function(cerr)
    if cerr then
      err, done = cerr, true
      return
    end
    pipe:write(payload)
    pipe:read_start(function(rerr, chunk)
      if rerr or not chunk then
        err, done = rerr, true
        return
      end
      chunks[#chunks + 1] = chunk
      if chunk:find("\n", 1, true) then
        done = true
      end
    end)
  end)
  if not vim.wait(TIMEOUT_MS, function() return done end, 1) then
    err = "timed out"
  end
  if not pipe:is_closing() then
    pipe:close()
  end

  local ok, reply = pcall(vim.json.decode, table.concat(chunks))
  if ok and type(reply) == "table" and type(reply.result) == "table" then
    return reply.result
  end
  local detail = ok and type(reply) == "table" and vim.json.encode(reply.error) or err or "no reply"
  vim.notify(("herdr %s failed: %s"):format(method, detail), vim.log.levels.WARN)
  return nil
end

---Focuses the neighbouring herdr pane. Returns false only at the outer edge;
---a failed request has already notified, so it stops the handoff too.
function M.move(side)
  local result = M.call("pane.edges")
  if not result then
    return true
  end
  -- A zoomed pane reports every edge, so unzoom before reading them.
  if result.edges.layout.zoomed then
    if not M.call("pane.zoom", { mode = "off" }) then
      return true
    end
    result = M.call("pane.edges")
    if not result then
      return true
    end
  end
  if result.edges[side] then
    return false
  end
  M.call("pane.focus_direction", { direction = side })
  return true
end

function M.resize(side, count)
  M.call("pane.resize", { direction = side, amount = RESIZE_RATIO * count })
end

return M
