return {
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup()

      vim.keymap.set("n", "<leader>gdw", "<cmd>DiffviewClose<CR>")
      vim.keymap.set("n", "<leader>gdd", "<cmd>DiffviewOpen<CR>")
      vim.keymap.set("n", "<leader>gdm", function()
        require("functions.get_default_branch")
        local default_branch = GetDefaultGitBranch()
        print(default_branch)
        vim.cmd.DiffviewOpen(default_branch)
      end
      )
      vim.keymap.set("n", "<leader>gdf", "<cmd>DiffviewFileHistory %<CR>")
    end,
  },
  {
    "ldelossa/gh.nvim",
    dependencies = {
      {
        "ldelossa/litee.nvim",
        config = function()
          require("litee.lib").setup()
        end,
      },
    },
    config = function()
      require("litee.gh").setup()
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gitsigns = require("gitsigns")
      vim.keymap.set('n', '<leader>tw', gitsigns.toggle_word_diff)
      gitsigns.setup({
        current_line_blame = true,
      })
    end,
  },
}
