{
  lib,
  pkgs,
  ...
}: {
  programs.nixvim.plugins = {
    none-ls = {
      enable = true;
      sources = {
        code_actions = {
          # gitsigns.enable = true;
        };
        diagnostics = {
          deadnix.enable = true;
          gitlint.enable = true;
          protolint.enable = true;
        };
        formatting = {
          alejandra.enable = true;
          markdownlint.enable = true;
          shfmt.enable = true;
        };
      };
    };
    nvim-lightbulb = {
      enable = true;
      settings.autocmd.enabled = true;
    };
    lsp = {
      enable = true;
      keymaps = {
        diagnostic = {
          "<leader>l" = "open_float";
        };
        lspBuf = {
          "gd" = "definition";
          "<leader>r" = "rename";
          "<leader>f" = "format";
          "<leader>a" = "code_action";
        };
        silent = true;
      };
      servers = {
        bashls.enable = true;
        clangd.enable = true;
        cmake.enable = true;
        cssls.enable = true;
        gopls.enable = true;
        html.enable = true;
        zls.enable = true;
        pyright.enable = true;
        texlab.enable = true;
        java-language-server.enable = true;
        rust-analyzer = {
          enable = true;
          settings = {
            checkOnSave = true;
            check.command = "clippy";
          };
          # cargo and rustc are managed per project with their own flakes.
          installCargo = false;
          installRustc = false;
        };
        nil_ls = {
          enable = true;
          settings = {
            formatting.command = [(lib.getExe pkgs.alejandra) "--quiet"];
          };
        };
        nixd.enable = true;
      };
    };
  };
}
