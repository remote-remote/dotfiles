return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-neotest/neotest-jest",
		"marilari88/neotest-vitest",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-jest")({
					jestCommand = "npx jest",
					env = { CI = true },
					cwd = function(path)
						return vim.fn.getcwd()
					end,
				}),
				require("neotest-vitest")({}),
			},
		})
	end,
}
