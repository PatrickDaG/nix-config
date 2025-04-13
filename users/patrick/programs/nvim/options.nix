{
  hm.programs.nixvim.opts = {
    # Set maximum undo levels
    undolevels = 1000000;
    # Persistent Undo
    undofile = true;

    # swap file save interval
    updatetime = 300;

    # Ignore *.o and *~ files in wildmenu
    wildignore = "*.o,*~";
    # Only complete the longest common prefix and list all results.
    # You can use the cursor keys to select an item in this list
    wildmode = [
      "list"
      "full"
    ];

    # set case handling
    ignorecase = true;
    smartcase = true;

    # ╓──────────────────╖
    # ║  Editor visuals  ║
    # ╙──────────────────╜

    # Enable true color in terminals
    termguicolors = true;
    # set font
    guifont = "FiraCode Nerd Font Mono:h10.5";
    # full mouse support
    mouse = "a";

    # Do not wrap text longer than the window's width
    wrap = false;

    # Show line numbers
    number = true;
    relativenumber = false;

    # Open new split window to left/down
    splitbelow = true;
    splitright = true;

    # Keep 2 lines around the cursor.
    scrolloff = 2;
    sidescrolloff = 2;

    # Set indentation of tabs to be equal to 4 spaces.
    tabstop = 4;
    shiftwidth = 4;
    softtabstop = 4;
    #round indentation to shifwidth
    shiftround = true;

    # ╓────────────────────╖
    # ║  Editing behavior  ║
    # ╙────────────────────╜

    # r = insert comment leader when hitting <Enter> in insert mode
    # q = allow explicit formatting with gq
    # j = remove comment leaders when joining lines if it makes sense
    formatoptions = "rqj";

    # Allow the curser to be positioned on cells that have no actual character;
    # Like moving beyond EOL or on any visual 'space' of a tab character
    virtualedit = "all";

    # Do not include line ends in past the-line selections
    selection = "old";

    # Use smart auto indenting for all file types
    smartindent = true;

    # Only wait 20 milliseconds for characters to arrive (see :help timeout)
    timeoutlen = 500; # wait for whichkey
    ttimeoutlen = 20;

    # Disable timeout, set ttimeout (only timeout on keycodes)
    timeout = true;
    ttimeout = true;

    # replace grep with ripgrep
    grepprg = "rg --vimgrep --smartcase --follow";
  };
}
