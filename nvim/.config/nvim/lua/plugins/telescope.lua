return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.4",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
    config = function()
      local builtin = require("telescope.builtin")
      local action_state = require('telescope.actions.state')
      local actions = require('telescope.actions')
      -- find file
      vim.keymap.set("n", "<leader>ff", function()
        builtin.find_files()
      end, {})
      vim.keymap.set("n", "<leader>fF", function()
        builtin.find_files({ no_ignore = true })
      end, {})
      vim.keymap.set("n", "<leader>fg", builtin.git_status, {})
      vim.keymap.set("n", "<leader>ft", function()
        builtin.live_grep()
      end)
      vim.keymap.set("n", "<leader>fT", function()
        builtin.live_grep({
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
      end)

      -- grep string
      vim.keymap.set("n", "<leader>fw", function()
        builtin.grep_string()
      end)


      vim.keymap.set("n", "<leader>fn", function()
        builtin.live_grep({
          additional_args = { "--files-with-matches" },
        })
      end, { desc = "Grep files (filenames only)" })

      local buffer_searcher
      buffer_searcher = function()
        builtin.buffers({
          sort_mru = true,
          ignore_current_buffer = true,
          show_all_buffers = false,
          attach_mappings = function(prompt_bufnr, map)
            local refresh_buffer_searcher = function()
              actions.close(prompt_bufnr)
              vim.schedule(buffer_searcher)
            end

            local delete_buf = function()
              local selection = action_state.get_selected_entry()
              vim.api.nvim_buf_delete(selection.bufnr, { force = true })
              refresh_buffer_searcher()
            end

            local delete_multiple_buf = function()
              local picker = action_state.get_current_picker(prompt_bufnr)
              local selection = picker:get_multi_selection()
              for _, entry in ipairs(selection) do
                vim.api.nvim_buf_delete(entry.bufnr, { force = true })
              end
              refresh_buffer_searcher()
            end

            map('n', 'dd', delete_buf)
            map('n', '<C-d>', delete_multiple_buf)
            map('i', '<C-d>', delete_multiple_buf)

            return true
          end
        })
      end

      vim.keymap.set("n", "<leader>fb", buffer_searcher, {})

      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!.git/",
          },
        },
        pickers = {
          find_files = {
            find_command = { "rg", "--files", "--hidden", "--glob=!.git/" },
          },
          lsp_references = {
            show_line = false
          },
          colorscheme = {
            enable_preview = true
          }
        },
      })
    end,
  }
}
