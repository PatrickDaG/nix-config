local map = vim.api.nvim_set_keymap
local opts = {noremap = true, silent = true}

function _G.whitespace_visibility()
    if vim.api.nvim_eval("&buftype") == "nofile" then
        vim.cmd('execute "DisableWhitespace"')
    else
        vim.cmd('execute "EnableWhitespace"')
    end
end

vim.cmd("autocmd BufEnter * lua whitespace_visibility()")

-- Strip whitespace
map('n', '<leader>$', ':StripWhitespace<CR>', opts)
