return {
  dir = vim.fn.stdpath("config") .. "/lua/agent-tours",
  name = "agent-tours",
  -- VeryLazy never fires without a UI, so the command stubs matter for
  -- `nvim --headless` runs as well as for first use.
  event = "VeryLazy",
  cmd = { "AgentTour", "AgentTourQuit", "AgentTourNext", "AgentTourPrev", "AgentTourSteps", "AgentTourQuickfix" },
  config = function()
    require("agent-tours").setup()
  end,
  -- <leader>t is neotest's prefix, so the tour lives under <leader>T.
  keys = {
    { "]t",         function() require("agent-tours").next() end,        desc = "Tour: next step" },
    { "[t",         function() require("agent-tours").prev() end,        desc = "Tour: previous step" },
    { "<leader>To", function() require("agent-tours").open() end,        desc = "Tour: open" },
    { "<leader>Ts", function() require("agent-tours").steps() end,       desc = "Tour: pick a step" },
    { "<leader>Tq", function() require("agent-tours").to_quickfix() end, desc = "Tour: dump to quickfix" },
    { "<leader>Tx", function() require("agent-tours").quit() end,        desc = "Tour: quit" },
  },
}
