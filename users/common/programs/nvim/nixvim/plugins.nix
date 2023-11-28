{
  imports = [
    ./plugins/lsp.nix
    ./plugins/cmp.nix
    ./plugins/alpha.nix
    ./plugins/neo-tree.nix
  ];
  programs.nixvim.plugins = {
    lualine = {
      extensions = [
        "nvim-tree"
        "quickfix"
        "fugitive"
      ];
    };
    indent-blankline = {
      enable = true;
      extraOptions = {
        exclude.buftypes = ["help" "terminal" "nofile"];
        exclude.filetypes = ["terminal" "lsp-info"];
      };
    };
    gitsigns = {
      enable = true;
    };
    diffview.enable = true;
    treesitter = {
      enable = true;
      indent = true;
      nixvimInjections = true;
    };
    treesitter-context.enable = true;
    vim-matchup.enable = true;
    comment-nvim.enable = true;
    # Fzf picker for arbitrary stuff
    telescope = {
      enable = true;
      extensions = {
        fzf-native.enable = true;
      };
    };

    # Undo tree
    undotree = {
      enable = true;
      focusOnToggle = true;
      windowLayout = 4;
    };

    # Quickfix menu
    trouble.enable = true;
    # Highlight certain keywords
    todo-comments.enable = true;
    fidget.enable = true;
    nvim-colorizer.enable = true;
  };
}
