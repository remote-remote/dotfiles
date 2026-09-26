return {
  "remote-remote/virgil.nvim",
  cmd = { "Virgil", "VirgilQuit", "VirgilNext", "VirgilPrev", "VirgilSteps", "VirgilQuickfix" },
  opts = {},
  -- <leader>t is neotest's prefix, so the trail lives under <leader>T.
  keys = {
    { "]t",         function() require("virgil").next() end,        desc = "Trail: next step" },
    { "[t",         function() require("virgil").prev() end,        desc = "Trail: previous step" },
    { "<leader>To", function() require("virgil").open() end,        desc = "Trail: open" },
    { "<leader>Ts", function() require("virgil").steps() end,       desc = "Trail: pick a step" },
    { "<leader>Tq", function() require("virgil").to_quickfix() end, desc = "Trail: dump to quickfix" },
    { "<leader>Tx", function() require("virgil").quit() end,        desc = "Trail: quit" },
  },
}
