-- global keybinds
vim.g.mapleader = " "

local map = vim.keymap.set
local opts = {noremap = true, silent = true}


-- change window with alt
map("", "<M-down>" , "<down>" , opts)
map("", "<M-up>"   , "<up>"   , opts)
map("", "<M-left>" , "<left>" , opts)
map("", "<M-right>", "<right>", opts)

map("", "<M-r>" , "<down>" , opts)
map("", "<M-l>"   , "<up>"   , opts)
map("", "<M-n>" , "<left>" , opts)
map("", "<M-s>", "<right>", opts)

-- scroll with cursor loch
map("" , "<S-down>" , ""   , opts)
map("" , "<S-up>"   , ""   , opts)
map("i", "<S-down>" , "a", opts)
map("i", "<S-up>"   , "a", opts)
