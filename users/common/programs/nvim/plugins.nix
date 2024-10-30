{
  imports = [
    ./plugins/lsp.nix
    ./plugins/cmp.nix
    ./plugins/alpha.nix
    ./plugins/neo-tree.nix
  ];
  hm.programs.nixvim.plugins = {
    web-devicons.enable = true;
    which-key.enable = true;
    lualine = {
      enable = true;
      settings = {
        extensions = [
          "fzf"
          "nvim-dap-ui"
          "symbols-outline"
          "trouble"
          "neo-tree"
          "quickfix"
          "fugitive"
        ];
        component_separators.left = "";
        component_separators.right = "";
        section_separators.left = "";
        section_separators.right = "";
        sections = {
          lualine_a = [ "mode" ];
          lualine_b = [
            "branch"
            "filename"
          ];
          lualine_c = [
            "diff"
            "diagnostics"
          ];
          lualine_x = [
            "encoding"
            "fileformat"
            "filetype"
          ];
          lualine_y = [ "progress" ];
          lualine_z = [ "location" ];
        };
        inactiveSections = {
          lualine_a = [ "filename" ];
          lualine_b = [ ];
          lualine_c = [ "diagnostics" ];
          lualine_x = [ ];
          lualine_y = [ ];
          lualine_z = [ "location" ];
        };
      };
    };
    fugitive.enable = true;
    neogit.enable = true;
    notify.enable = true;
    rainbow-delimiters.enable = true;
    rustaceanvim = {
      enable = true;
      settings.server.default_settings.files.excludeDirs = [ ".direnv" ];
    };
    indent-blankline = {
      enable = true;
      settings = {
        exclude.buftypes = [
          "help"
          "terminal"
          "nofile"
        ];
        exclude.filetypes = [
          "terminal"
          "lsp-info"
        ];
      };
    };
    gitsigns = {
      enable = true;
    };
    diffview.enable = true;
    treesitter = {
      enable = true;
      settings.indent.enable = true;
      nixvimInjections = true;
    };
    #treesitter-context.enable = true;
    vim-matchup.enable = true;
    comment.enable = true;
    # Fzf picker for arbitrary stuff
    telescope = {
      enable = true;
      extensions = {
        fzf-native.enable = true;
        frecency.enable = true;
      };
      enabledExtensions = [ "notify" ];
      keymaps = {
        "<leader>gf" = {
          action = "git_files";
        };
        "<leader>gg" = "live_grep";
      };
    };

    # Undo tree
    undotree = {
      enable = true;
      settings = {
        WindowLayout = 4;
        focusOnToggle = true;
      };
    };

    # Quickfix menu
    trouble.enable = true;
    # Highlight certain keywords
    todo-comments.enable = true;
    fidget.enable = true;
    nvim-colorizer.enable = true;
  };
}
