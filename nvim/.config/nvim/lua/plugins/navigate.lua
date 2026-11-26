-- Local plugin: local/navigate.nvim. ctrl-hjkl moves and alt-hjkl resizes
-- across nvim splits, herdr or tmux panes, and AeroSpace windows.
local keys = {}
for key, side in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  keys[#keys + 1] = { "<C-" .. key .. ">", function() require("navigate").move(side) end, desc = "Navigate " .. side }
  -- Under tmux, better-vim-tmux-resizer (plugins/tmux.lua) owns <M-hjkl>.
  if not vim.env.TMUX then
    keys[#keys + 1] = { "<M-" .. key .. ">", function() require("navigate").resize(side) end, desc = "Resize " .. side }
  end
end

return {
  {
    dir = vim.fn.stdpath("config") .. "/local/navigate.nvim",
    name = "navigate.nvim",
    keys = keys,
  },
}
