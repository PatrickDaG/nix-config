{
  pkgs,
  lib,
  ...
}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
    withNodeJs = true;
    extraPackages = with pkgs; [
      # treesitter
      clang_15
      clang-tools_15
      # tabnine complition braucht unzip
      unzip
      # telescope fzf native braucht make
      gnumake
      # telescope braucht die
      ripgrep
      fd
    ];
  };

  xdg.configFile.nvim = {
    recursive = true;
    source = ./.;
  };
  home.persistence."/state".directories = [
    ".local/share/nvim"
    ".local/state/nvim"
    ".cache/nvim"
  ];
  home.shellAliases.nixvim = lib.getExe (pkgs.nixvim.makeNixvim {
    package = pkgs.neovim-clean;
    colorschemes.onedark.enable = true;
    options = import ./nixvim/options.nix;
    globals.mapleader = " ";
    keymaps = let
      options = {
        noremap = true;
        silent = true;
      };
    in [
      {
        key = "<M-down>";
        action = "<C-w><down>";
        inherit options;
      }
      {
        key = "<M-up>";
        action = "<C-w><up>";
        inherit options;
      }
      {
        key = "<M-left>";
        action = "<C-w><left>";
        inherit options;
      }
      {
        key = "<M-right>";
        action = "<C-w><right>";
        inherit options;
      }

      {
        key = "<M-r>";
        action = "<C-w><down>";
        inherit options;
      }
      {
        key = "<M-l>";
        action = "<C-w><up>";
        inherit options;
      }
      {
        key = "<M-n>";
        action = "<C-w><left>";
        inherit options;
      }
      {
        key = "<M-s>";
        action = "<C-w><right>";
        inherit options;
      }

      # scroll with cursor lock
      {
        key = "<S-down>";
        action = "<C-e>";
        inherit options;
      }
      {
        key = "<S-up>";
        action = "<C-y>";
        inherit options;
      }
      {
        key = "<S-down>";
        action = "<C-[><C-e>a";
        inherit options;
        mode = "i";
      }
      {
        key = "<S-up>";
        action = "<C-[><C-y>a";
        inherit options;
        mode = "i";
      }
    ];
  });
}
