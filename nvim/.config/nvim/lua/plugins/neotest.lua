return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    -- "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "zidhuss/neotest-minitest",
    "jfpedroza/neotest-elixir",
    "nvim-neotest/neotest-jest",
    "marilari88/neotest-vitest",
  },
  config = function()
    local neotest = require("neotest")

    vim.keymap.set("n", "<leader>tt", function()
      neotest.run.run()
    end)

    vim.keymap.set("n", "<leader>tT", function()
      neotest.run.run("")
    end)

    vim.keymap.set("n", "<leader>ts", function()
      neotest.summary.toggle()
    end)

    vim.keymap.set("n", "<leader>to", function()
      neotest.output.open({ enter = true, focus = true })
    end)

    vim.keymap.set("n", "<leader>td", function()
      neotest.run.run({ strategy = "dap" })
    end)

    vim.keymap.set("n", "<leader>tr", function() end)

    neotest.setup({
      adapters = {
        require("neotest-jest")({
          jestCommand = function()
            local cwd = vim.fn.getcwd()
            local bin = cwd .. "/node_modules/.bin/jest"
            if vim.fn.filereadable(bin) == 1 then
              return bin
            end
            return "npx jest"
          end,
          env = { CI = "true", NODE_ENV = "test", JEST_BAIL = "false" },
          cwd = function()
            return vim.fn.getcwd()
          end,
          jestConfigFile = function()
            local cwd = vim.fn.getcwd()
            if vim.fn.filereadable(cwd .. "/jest.config.ts") == 1 then
              return cwd .. "/jest.config.ts"
            end
            if vim.fn.filereadable(cwd .. "/jest.config.js") == 1 then
              return cwd .. "/jest.config.js"
            end
            return nil
          end,
          strategy_config = function(default_config)
            if not default_config.args then
              return default_config
            end
            table.insert(default_config.args, 1, "--runInBand")
            table.insert(default_config.args, "--testTimeout")
            table.insert(default_config.args, "60000")
            default_config.resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            }
            default_config.sourceMaps = true
            return default_config
          end,
        }),
        require("neotest-minitest")({}),
        require("neotest-vitest")({}),
        require("neotest-elixir")({
          -- -- The Mix task to use to run the tests
          -- -- Can be a function to return a dynamic value.
          -- -- Default: "test"
          -- mix_task = {"my_custom_task"},
          -- -- Other formatters to pass to the test command as the formatters are overridden
          -- -- Can be a function to return a dynamic value.
          -- -- Default: {"ExUnit.CLIFormatter"}
          -- extra_formatters = {"ExUnit.CLIFormatter", "ExUnitNotifier"},
          -- -- Extra test block identifiers
          -- -- Can be a function to return a dynamic value.
          -- -- Block identifiers "test", "feature" and "property" are always supported by default.
          -- -- Default: {}
          -- extra_block_identifiers = {"test_with_mock"},
          -- -- Extra arguments to pass to mix test
          -- -- Can be a function that receives the position, to return a dynamic value
          -- -- Default: {}
          -- args = {"--trace"},
          -- -- Command wrapper
          -- -- Must be a function that receives the mix command as a table, to return a dynamic value
          -- -- Default: function(cmd) return cmd end
          -- post_process_command = function(cmd)
          --   return vim.iter({{"env", "FOO=bar"}, cmd}):flatten():totable()
          -- end,
          -- -- Delays writes so that results are updated at most every given milliseconds
          -- -- Decreasing this number improves snappiness at the cost of performance
          -- -- Can be a function to return a dynamic value.
          -- -- Default: 1000
          -- write_delay = 1000,
          -- -- The pattern to match test files
          -- -- Default: "_test.exs$"
          -- test_file_pattern = ".test.exs$",
          -- -- Function to determine whether a directory should be ignored
          -- -- By default includes root test directory and umbrella apps' test directories
          -- -- Params:
          -- -- - name (string) - Name of directory
          -- -- - rel_path (string) - Path to directory, relative to root
          -- -- - root (string) - Root directory of project
          -- filter_dir = function(name, rel_path, root)
          --   return rel_path == "test"
          --       or rel_path == "lib"
          --       or vim.startswith(rel_path, 'test/')
          --       or vim.startswith(rel_path, 'lib/')
          -- end,
        }),
      },
    })
  end,
}
