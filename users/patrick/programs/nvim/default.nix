{ pkgs, ... }:
{
  imports = [
    ./keybinds.nix
    ./options.nix
    ./plugins.nix
  ];
  hm = {
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
      extraConfigLuaPost =
        # lua
        ''
          vim.notify = require("notify")
          require("window-picker").setup {
            hint = "floating-big-letter",
            filter_rules = {
              bo = {
                filetype = { "neo-tree", "neo-tree-popup", "notify", "quickfix" },
                buftype = { "terminal", "quickfix", "prompt" },
              },
            },
            floating_big_letter = {
              font = "ansi-shadow",
            },
            selection_chars = "EITCAUDJÄÜVF",
            show_prompt = false,
          }
        '';
    };
    home.sessionVariables.EDITOR = "nvim";
    home.shellAliases.vim = "nvim";
    home.shellAliases.vi = "nvim";
    home.shellAliases.vimdiff = "nvim -d";
    home.persistence."/state".directories = [
      ".local/share/nvim"
      ".local/state/nvim"
      ".cache/nvim"
    ];
  };
}
