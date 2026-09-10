local function multi_move(dir)
  if vim.env.HERDR_PANE_ID ~= nil then
    if dir == "left" then
      require('herdr-splits').move_cursor_left()
    elseif dir == "right" then
      require('herdr-splits').move_cursor_right()
    end
  elseif vim.g.tmux_version ~= nil then
    if dir == "left" then
      vim.cmd("TmuxNavigateLeft")
    elseif dir == "right" then
      vim.cmd("TmuxNavigateLeft")
    end
  end
end

return {
  "stevearc/oil.nvim",
  opts = {},
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      view_options = {
        show_hidden = true,
      },
      lsp_file_methods = {
        autosave_changes = true
      },
      keymaps = {
        ["<C-h>"] = {
          callback = function()
            multi_move("left")
          end,
          desc = "Navigate left"
        },
        ["<C-l>"] = {
          callback = function()
            multi_move("right")
          end,
          desc = "Navigate right"
        },
        ["<C-\\>"] = { "actions.select_vsplit", desc = "Open in vertical split" },
        ["<C-_>"] = { "actions.select_split", desc = "Open in horizontal split" },
        ["<leader>ff"] = {
          callback = function()
            require("telescope.builtin").find_files({ cwd = require("oil").get_current_dir() })
          end,
          desc = "Find files in oil dir",
        },
        ["<leader>fF"] = {
          callback = function()
            require("telescope.builtin").find_files({ cwd = require("oil").get_current_dir(), no_ignore = true })
          end,
          desc = "Find files in oil dir (no ignore)",
        },
        ["<leader>ft"] = {
          callback = function()
            require("telescope.builtin").live_grep({ cwd = require("oil").get_current_dir() })
          end,
          desc = "Live grep in oil dir",
        },
        ["<leader>fT"] = {
          callback = function()
            require("telescope.builtin").live_grep({
              cwd = require("oil").get_current_dir(),
              no_ignore = true,
              vimgrep_arguments = {
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
                "-uu",
              },
            })
          end,
          desc = "Live grep in oil dir (no ignore)",
        },
      },
    })
    vim.keymap.set("n", "<leader>-", ":Oil <CR>", { desc = "Open Oil in parent directory of file" })
  end,
}
