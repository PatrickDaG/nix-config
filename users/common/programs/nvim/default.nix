{pkgs, ...}: {
  imports = [
    ./nixvim/keybinds.nix
    ./nixvim/options.nix
    ./nixvim/plugins.nix
  ];
  programs.nixvim = {
    enable = true;
    luaLoader.enable = true;
    files."ftplugin/nix.lua".extraConfigLua = ''
      vim.opt_local.expandtab = true
      vim.opt_local.tabstop = 2
      vim.opt_local.shiftwidth = 2
      vim.opt_local.softtabstop = 2
    '';
    globals.mapleader = " ";
    extraPlugins = with pkgs.vimPlugins; [
      vim-better-whitespace
      dressing-nvim
      nvim-window-picker
      nabla-nvim
      vim-gnupg
      onedark-nvim
    ];
    extraConfigLuaPre = ''
      require("onedark").load()
    '';
    extraConfigLuaPost = ''
    '';
  };
  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.vim = "nvim";
  home.sessionVariables.vi = "nvim";
  home.shellAliases.vimdiff = "nvim -d";
  home.persistence."/state".directories = [
    ".local/share/nvim"
    ".local/state/nvim"
    ".cache/nvim"
  ];
}
