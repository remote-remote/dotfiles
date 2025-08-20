-- init.lua is always an entrypoint
-- everything in ./lua/ can be imported with `require()`
--
require("keymaps")
require("lazy-init")
require("lsp")
require("options")
require("which-key")
require("functions/git_permalink")
