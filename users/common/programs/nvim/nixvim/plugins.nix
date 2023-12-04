{
  imports = [
    ./plugins/lsp.nix
    ./plugins/cmp.nix
    ./plugins/alpha.nix
    ./plugins/neo-tree.nix
  ];
  programs.nixvim.plugins = {
    lualine = {
      enable = true;
      extensions = ["fzf" "nvim-dap-ui" "symbols-outline" "trouble" "neo-tree" "quickfix" "fugitive"];
      componentSeparators.left = "";
      componentSeparators.right = "";
      sectionSeparators.left = "";
      sectionSeparators.right = "";
      sections = {
        lualine_a = ["mode"];
        lualine_b = ["branch" "filename"];
        lualine_c = ["diff" "diagnostics"];
        lualine_x = ["encoding" "fileformat" "filetype"];
        lualine_y = ["progress"];
        lualine_z = ["location"];
      };
      inactiveSections = {
        lualine_a = ["filename"];
        lualine_b = [];
        lualine_c = ["diagnostics"];
        lualine_x = [];
        lualine_y = [];
        lualine_z = ["location"];
      };
    };
    fugitive.enable = true;
    notify.enable = true;
    rust-tools = {
      enable = true;
      server.check.command = "clippy";
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
      enabledExtensions = ["notify"];
      keymaps = {
        "<leader>gf" = {
          action = "git_files";
          desc = "Telescope Git Files";
        };
        "<leader>gg" = "live_grep";
      };
      keymapsSilent = true;
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
