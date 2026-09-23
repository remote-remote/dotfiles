-- leader
vim.keymap.set("n", " ", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "

-- buffer navigation
vim.keymap.set("n", "<M-Tab>", ":bn<CR>")
vim.keymap.set("n", "<M-S-Tab>", ":bp<CR>")
vim.keymap.set("n", "<leader>w", ":bd<CR>")

-- split / pane / window navigation
for key, side in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  vim.keymap.set("n", "<C-" .. key .. ">", function() require("navigate").move(side) end, { desc = "Navigate " .. side })
end

-- remove search highlight
vim.keymap.set("n", "<leader>/", ":noh<CR>")

-- toggle hidden characters
vim.keymap.set("n", "<leader>;", function()
  if vim.o.list then
    vim.o.list = false
  else
    vim.o.list = true
  end
end)

require("functions/qf-dd")
require("functions/goto_rails_test")
