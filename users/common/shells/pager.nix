{pkgs, ...}: let
  initLua = pkgs.writeText "init.lua" ''
    vim.opt.buftype = "nowrite"
    vim.opt.history=0
    vim.opt.backup=false
    vim.opt.modeline=false
    vim.opt.shelltemp=false
    vim.opt.swapfile=false
    vim.opt.undofile=false
    vim.opt.writebackup = false
    vim.opt.shada-file = vim.fn.stdpath "state" .. "/shada/man.shada"
  '';
  nvimPager = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped neovimConfig;
  neovimConfig =
    pkgs.neovimUtils.makeNeovimConfig {
      wrapRc = false;
      withPython3 = false;
    }
    // {
      wrapperArgs = ["--add-flags" "--clean -u ${initLua}"];
    };
in {
  home.sessionVariables.MANPAGER = "${nvimPager}/bin/nvim '+Man!'";
}
