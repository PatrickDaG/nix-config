
--required programs
--ripgrep
--fd
--?pynvim
--git
--nvim




--basic global settings
require "core.config"
require "core.keybinds"
require "core.lsp"

--set venv
vim.g.python3_host_prog=vim.fn.stdpath("data").."/venv/bin/python3"
