return {
  "stevearc/oil.nvim",
  opts = {},
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      keymaps = {
        ["<C-h>"] = { callback = function() vim.cmd("TmuxNavigateLeft") end, desc = "Navigate left" },
        ["<C-l>"] = { callback = function() vim.cmd("TmuxNavigateRight") end, desc = "Navigate right" },
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
                "-u",
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
