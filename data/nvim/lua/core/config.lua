local opt = vim.opt

-- Set maximum undo levels
opt.undolevels = 1000000
-- Persistent Undo
opt.undofile = true
opt.undodir = vim.fn.stdpath("cache") .. "/undo"

-- swap file save interval
opt.updatetime = 300

-- Ignore *.o and *~ files in wildmenu
opt.wildignore = "*.o,*~"
-- Only complete the longest common prefix and list all results.
-- You can use the cursor keys to select an item in this list
opt.wildmode = {"list", "full"}

-- set case handling
opt.ignorecase = true
opt.smartcase = true

-- ╓──────────────────╖
-- ║  Editor visuals  ║
-- ╙──────────────────╜

-- Enable true color in terminals
opt.termguicolors = true
-- set font
opt.guifont = "FiraCode Nerd Font Mono:h10.5"
-- full mouse support
opt.mouse = "a"

-- Do not wrap text longer than the window's width
opt.wrap = false

-- Show line numbers
opt.number = true
opt.relativenumber = false

-- Keep 2 lines around the cursor.
opt.scrolloff = 2
opt.sidescrolloff = 2

-- Set indentation of tabs to be equal to 4 spaces.
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
--round indentation to shifwidth
opt.shiftround  =  true


-- ╓────────────────────╖
-- ║  Editing behavior  ║
-- ╙────────────────────╜

-- r = insert comment leader when hitting <Enter> in insert mode
-- q = allow explicit formatting with gq
-- j = remove comment leaders when joining lines if it makes sense
opt.formatoptions = "rqj"

-- Allow the curser to be positioned on cells that have no actual character;
-- Like moving beyond EOL or on any visual 'space' of a tab character
opt.virtualedit = "all"

-- Do not include line ends in past the-line selections
opt.selection = "old"

-- Use smart auto indenting for all file types
opt.smartindent = true

-- Only wait 20 milliseconds for characters to arrive (see :help timeout)
opt.timeoutlen = 20
opt.ttimeoutlen = 20

-- Disable timeout, set ttimeout (only timeout on keycodes)
opt.timeout = false
opt.ttimeout = true

-- replace grep with ripgrep
opt.grepprg = "rg --vimgrep --smartcase --follow"

