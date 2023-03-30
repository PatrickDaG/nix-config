-- global keybinds
vim.g.mapleader = " "

local map = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}


-- change window with alt
map("", "<M-down>" , "<down>" , { noremap = true, silent = true })
map("", "<M-up>"   , "<up>"   , { noremap = true, silent = true })
map("", "<M-left>" , "<left>" , { noremap = true, silent = true })
map("", "<M-right>", "<right>", { noremap = true, silent = true })

map("", "<M-r>" , "<down>" , { noremap = true, silent = true })
map("", "<M-l>"   , "<up>"   , { noremap = true, silent = true })
map("", "<M-n>" , "<left>" , { noremap = true, silent = true })
map("", "<M-s>", "<right>", { noremap = true, silent = true })

-- scroll with cursor loch
map("" , "<S-down>" , ""   , { noremap = true, silent = true })
map("" , "<S-up>"   , ""   , { noremap = true, silent = true })
map("i", "<S-down>" , "a", { noremap = true, silent = true })
map("i", "<S-up>"   , "a", { noremap = true, silent = true })
