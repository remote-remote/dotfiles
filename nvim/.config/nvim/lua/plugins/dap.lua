return {
  {
    "microsoft/vscode-js-debug",
    build = "npm install --legacy-peer-deps && npx gulp dapDebugServer && rm -rf out && mv dist out",
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "microsoft/vscode-js-debug",
    },
    config = function()
      local dap = require("dap")

      local js_debug_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"

      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            js_debug_path .. "/out/src/dapDebugServer.js",
            "${port}",
          },
        },
      }

      for _, language in ipairs({ "typescript", "javascript" }) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            name = "Launch file",
            request = "launch",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Vitest debug",
            cwd = "${workspaceFolder}",
            program = "${workspaceFolder}/node_modules/vitest/vitest.mjs",
            args = { "run", "${file}" },
            autoAttachChildProcesses = true,
            smartStep = true,
            skipFiles = { "<node_internals>/**", "node_modules/**" },
          },
        }
      end

      vim.keymap.set("n", "<leader>b", function()
        dap.toggle_breakpoint()
      end)
      vim.keymap.set("n", "<F5>", function()
        dap.continue()
      end)
      vim.keymap.set("n", "<F10>", function()
        dap.step_over()
      end)
      vim.keymap.set("n", "<F11>", function()
        dap.step_into()
      end)
      vim.keymap.set("n", "<F12>", function()
        dap.step_out()
      end)
      vim.keymap.set("n", "<leader>dx", function()
        dap.terminate()
      end)
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      dapui.setup({
        mappings = {
          expand = { "<CR>", "zo", "zc", "<2-LeftMouse>" },
          edit = "<leader>de",
        },
        layouts = {
          {
            elements = {
              { id = "stacks",      size = 0.25 },
              { id = "breakpoints", size = 0.15 },
              { id = "watches",     size = 0.2 },
              { id = "scopes",      size = 0.4 },
            },
            size = 0.25,
            position = "left",
          },
          {
            elements = {
              { id = "repl",    size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 20,
            position = "bottom",
          },
        },
      })
    end,
  },
  {
    "suketa/nvim-dap-ruby",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("dap-ruby").setup()
    end,
  },
}
