{pkgs, ...}: let
  initLua = pkgs.writeText "init.lua" ''
       vim.opt.buftype = "nowrite"
       vim.opt.backup=false
       vim.opt.modeline=false
       vim.opt.shelltemp=false
       vim.opt.swapfile=false
       vim.opt.undofile=false
       vim.opt.writebackup = false
       vim.opt.shada-file = vim.fn.stdpath "state" .. "/shada/man.shada"
    vim.opt.virtualedit = "all"
    vim.opt.splitkeep = "screen"

    vim.opt.termguicolors = false

    vim.keymap.set('n', '<CR>', '<C-]>', {silent = true, desc = "Jump to tag under cursor})
    vim.keymap.set('n', '<Bs>', ':pop<CR>', {silent = true, desc = "Jump to tag under cursor})
    vim.keymap.set('n', '<C-Left>', ':pop<CR>', {silent = true, desc = "Jump to tag under cursor})
    vim.keymap.set('n', '<C-Right>', ':tag<CR>', {silent = true, desc = "Jump to tag under cursor})
  '';
  nvimPager = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped neovimConfig;
  neovimConfig =
    pkgs.neovimUtils.makeNeovimConfig {
      wrapRc = false;
      withPython3 = false;
      withRuby = false;
    }
    // {
      wrapperArgs = ["--add-flags" "--clean -u ${initLua}"];
    };
in {
  home.sessionVariables.MANPAGER = "${nvimPager}/bin/nvim '+Man!'";
}
