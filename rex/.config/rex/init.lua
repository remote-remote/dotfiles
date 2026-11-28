-- Migrated from ~/.config/tmux/tmux.conf and ~/.config/herdr/config.toml (prefix ctrl+a).

-- tmux
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })
rex.bind("ctrl+a>shift+\\", "pane.split", { direction = "right" })
rex.bind("ctrl+a>-", "pane.split", { direction = "down" })
-- tmux and Herdr close the tab along with its last pane; Rex's pane.close doesn't.
rex.action{
  name = "close_pane_or_tab",
  title = "Close Pane (or Tab if Last)",
  run = function(ctx)
    local view, err = rex.session.view{}
    if view == nil then error(err, 0) end
    for _, w in ipairs(view.windows) do
      local count, here = 0, false
      for _, layer in ipairs(w.layers) do
        for _, b in ipairs(layer.blocks) do
          count = count + 1
          if b.block_id == ctx.block_id then here = true end
        end
      end
      if here then
        rex.client.queue(count == 1 and "client.tab.close" or "pane.close", {})
        return
      end
    end
    rex.client.queue("pane.close", {})
  end,
}
rex.bind("ctrl+a>x", "close_pane_or_tab")
rex.bind("ctrl+a>l", "client.tab.next")
rex.bind("ctrl+a>h", "client.tab.previous")
rex.bind("ctrl+a>shift+t", "client.tab.rename")

-- Herdr
rex.bind("ctrl+a>shift+s", "client.settings")
rex.bind("ctrl+a>shift+r", "client.config.reload")
rex.bind("ctrl+a>w", "session.switch")
rex.bind("ctrl+a>s", "session.switch")
rex.bind("ctrl+alt+k", "session.previous")
rex.bind("ctrl+alt+j", "session.next")
rex.bind("ctrl+a>c", "client.tab.new")
rex.bind("ctrl+a>z", "pane.zoom")
rex.bind("ctrl+a>b", "client.sidebar.toggle")

-- ctrl+hjkl as in tmux.conf:62-65 and herdr-nav: vim gets the key (navigate.nvim
-- handles it), otherwise focus the neighbouring pane, or AeroSpace at the edge.
local nav_keys = { left = "ctrl+h", down = "ctrl+j", up = "ctrl+k", right = "ctrl+l" }

local function is_vim(name)
  name = (name or ""):lower():gsub("^.*/", "")
  for _, p in ipairs({ "^g?l?n?vim?x?$", "^g?l?n?vim?x?diff$", "^g?view$" }) do
    if name:match(p) then return true end
  end
  return false
end

-- Also called by navigate.nvim's Rex backend (`rex do pane_focus_direction`)
-- when nvim reaches its own edge. moved = false means Rex is at its edge too.
rex.action{
  name = "pane_focus_direction",
  title = "Focus Pane Without Wrapping",
  args = { direction = "string" },
  run = function(ctx, args)
    local before = rex.session.view{}
    local after = rex.session.focus_direction{ direction = args.direction, wrap = false }
    return { moved = not (before and after and after.revision == before.revision) }
  end,
}

rex.action{
  name = "pane_nav",
  title = "Navigate Pane (vim-aware)",
  args = { direction = "string" },
  run = function(ctx, args)
    local dir = args.direction
    local proc = rex.block.call("com.superlogical.terminal", "process", { block_id = ctx.block_id })
    local fg = proc and proc.foreground
    if fg and (is_vim(fg.argv0) or is_vim(fg.path)) then
      rex.client.queue("pane.send_key", { key = nav_keys[dir] })
      return
    end
    local r = rex.invoke("pane_focus_direction", { direction = dir })
    if r and r.moved == false then
      rex.exec({ "/opt/homebrew/bin/aerospace", "focus", dir }, { timeout = 5 })
    end
  end,
}
rex.bind("ctrl+h", "pane_nav", { direction = "left" })
rex.bind("ctrl+j", "pane_nav", { direction = "down" })
rex.bind("ctrl+k", "pane_nav", { direction = "up" })
rex.bind("ctrl+l", "pane_nav", { direction = "right" })

-- Session picker, as tmux-picker / herdr-picker: live sessions first, then the
-- directories sessionizer-dirs offers. A directory whose basename (dots as
-- underscores, as tmux-picker names sessions) matches a live session's label is
-- shown only as that session. Picking a directory creates its session.
local function session_name(dir)
  return (dir:gsub("/+$", ""):match("[^/]+$") or dir):gsub("%.", "_")
end

local function tilde(path)
  local home = os.getenv("HOME")
  if path:sub(1, #home) == home then return "~" .. path:sub(#home + 1) end
  return path
end

rex.action{
  name = "session_picker",
  title = "Pick Session or Project…",
  run = function(ctx)
    local list, err = rex.call("session.list")
    if list == nil then error(err, 0) end

    local items, live = {}, {}
    for _, s in ipairs(list.sessions) do
      live[s.label] = true
      items[#items + 1] = {
        id = "s:" .. s.session_id,
        title = s.label,
        icon = "terminal",
        detail = s.session_id == ctx.session_id and "current" or nil,
      }
    end

    local dirs = rex.exec({ os.getenv("HOME") .. "/.local/bin/sessionizer-dirs" }, { timeout = 10 })
    if dirs and dirs.ok then
      for dir in dirs.stdout:gmatch("[^\n]+") do
        local name = session_name(dir)
        if not live[name] then
          items[#items + 1] = { id = "d:" .. dir, title = name, subtitle = tilde(dir), icon = "folder" }
        end
      end
    else
      rex.log("warn", "session_picker: sessionizer-dirs failed: " .. tostring(dirs and dirs.stderr or err))
    end

    local pick = rex.ui.pick{ title = "Sessions", placeholder = "Filter sessions and projects", items = items }
    if pick == nil then return end

    local session_id = pick:match("^s:(.*)")
    if session_id == nil then
      local dir = pick:sub(3)
      local created, cerr = rex.call("session.create", {
        label = session_name(dir),
        initial_windows = { {
          layout = rex.layout.block{ flavor = "com.superlogical.terminal.shell", options = { cwd = dir } },
        } },
      })
      if created == nil then error(cerr, 0) end
      session_id = created.session_id
    end
    rex.client.queue("session.select", { session_id = session_id })
  end,
}
rex.bind("ctrl+a>f", "session_picker")

-- Fonts and themes are Rex app settings, not init.lua settings. Run this from
-- the command palette to match kitty (kitty.conf font, kitty-themes vague.conf).
rex.action{
  name = "apply_kitty_look",
  title = "Apply Kitty Theme and Font",
  run = function()
    rex.client.queue("client.theme.import", { path = os.getenv("HOME") .. "/.config/rex/themes/vague" })
    rex.client.queue("client.setting.terminal.typography.font", { value = "MonaspiceKr Nerd Font Mono" })
    rex.client.queue("client.setting.terminal.typography.size", { value = 14 })
  end,
}
