-- return {
--   "nanozuki/tabby.nvim",
--   config = function()
--     vim.opt.sessionoptions:append("globals")
--     require("tabby").setup({
--       preset = "tab_only",
--     })
--   end,
-- }

return {
  "nanozuki/tabby.nvim",
  config = function()
    local function tab_label(tabid)
      local custom = require("tabby.feature.tab_name").get_raw(tabid)
      if custom ~= "" then
        return custom
      end

      local tabnr = vim.api.nvim_tabpage_get_number(tabid)
      local cwd = vim.fn.getcwd(-1, tabnr)
      local project = vim.fn.fnamemodify(cwd, ":t")

      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabid)) do
        local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
        if name:match("^codediff://") then
          return "  " .. project
        end
      end

      return project
    end

    local theme = {
      fill = "Normal",
      head = "TabLine",
      current_tab = "Normal",
      tab = "TabLine",
      win = "TabLine",
      tail = "TabLine",
    }

    require("tabby").setup({
      line = function(line)
        return {
          line.tabs().foreach(function(tab)
            local hl = tab.is_current() and theme.current_tab or theme.tab
            return {
              line.sep(" ", hl, theme.fill),
              tab_label(tab.id),
              line.sep(" ", hl, theme.fill),
              hl = hl,
              margin = "  ",
            }
          end),
          hl = theme.fill,
        }
      end,
    })
  end,
}
