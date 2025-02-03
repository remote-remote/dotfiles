return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.4",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
  },
  config = function()
    local builtin = require("telescope.builtin")
    -- find file
    vim.keymap.set("n", "<leader>ff", function()
      builtin.find_files()
    end, {})
    vim.keymap.set("n", "<leader>fF", function()
      builtin.find_files({ no_ignore = true })
    end, {})
    -- find git file
    vim.keymap.set("n", "<leader>fg", builtin.git_files, {})
    -- find text (live grep)
    vim.keymap.set("n", "<leader>ft", function()
      builtin.live_grep()
    end)
    vim.keymap.set("n", "<leader>fT", function()
      builtin.live_grep({
        no_ignore = true,
        vimgrep_arguments = { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', '-u' }
      }
      )
    end)

    -- grep string
    vim.keymap.set("n", "<leader>fw", function()
      builtin.grep_string()
    end)

    vim.keymap.set("n", "<leader>fb", function()
      builtin.buffers()
    end)
  end,
}
