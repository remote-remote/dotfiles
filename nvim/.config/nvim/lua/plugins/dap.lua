return {
	{
		"microsoft/vscode-js-debug",
		-- opt = true,
		build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
	},
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"nvim-neotest/nvim-nio",
		},
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"microsoft/vscode-js-debug",
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

			dapui.setup()
		end,
	},
	{
		{
			"suketa/nvim-dap-ruby",
			dependencies = {
				"mfussenegger/nvim-dap",
			},
			config = function()
				require("dap-ruby").setup()
			end,
		},
	},
	{
		"mxsdev/nvim-dap-vscode-js",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		config = function()
			require("dap-vscode-js").setup({
				adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
				debugger_path = "/Users/jasonamador/.local/share/nvim/lazy/vscode-js-debug",
				log_console_level = vim.log.levels.DEBUG,
			})

			vim.keymap.set("n", "<leader>db", function()
				require("dap").toggle_breakpoint()
			end)

			for _, language in ipairs({ "typescript", "javascript" }) do
				require("dap").configurations[language] = {
					{
						type = "pwa-node",
						name = "node launch",
						request = "launch",
						program = "${file}",
						cwd = vim.fn.getcwd(),
						port = 9229,
					},
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch Test Program (pwa-node with vitest)",
						cwd = vim.fn.getcwd(),
						program = "${workspaceFolder}/node_modules/vitest/vitest.mjs",
						args = { "run", "${file}" }, -- "--config", "${workspaceFolder}/vitest.workspace.ts" },
						autoAttachChildProcesses = true,
						smartStep = true,
						skipFiles = { "<node_internals>/**", "node_modules/**" },
					},
				}
			end
		end,
	},
}
