-- global keybinds
vim.g.mapleader = " "

local map = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}


-- change window with alt
map("", "<M-down>" , "<down>" , { noremap = true, silent = true })
map("", "<M-up>"   , "<up>"   , { noremap = true, silent = true })
map("", "<M-left>" , "<left>" , { noremap = true, silent = true })
map("", "<M-right>", "<right>", { noremap = true, silent = true })

-- scroll with cursor loch
map("" , "<S-down>" , ""   , { noremap = true, silent = true })
map("" , "<S-up>"   , ""   , { noremap = true, silent = true })
map("i", "<S-down>" , "a", { noremap = true, silent = true })
map("i", "<S-up>"   , "a", { noremap = true, silent = true })


-- Plugin: LSP
map("n", "gD",         "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
map("n", "gd",         "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
map("n", "K",          "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
map("n", "gI",         "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
map("n", "gk",         "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
map("n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
map("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
map("n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
map("n", "gt",         "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
map("n", "<leader>r",  "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
map("n", "<leader>A",  "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
map("n", "gr",         "<cmd>lua vim.lsp.buf.references()<CR>", opts)
map("n", "gl",         "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
map("n", "gp",         "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
map("n", "gn",         "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
map("n", "<leader>q",  "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
map("n", "<leader>f",  "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

-- Plugin: EasyAlign
map("n", "<leader>a", "<Plug>(EasyAlign)", {silent = true})
map("v", "<leader>a", "<Plug>(EasyAlign)", {silent = true})
