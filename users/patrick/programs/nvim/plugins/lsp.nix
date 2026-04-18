{ lib, pkgs, ... }:
{
  hm.programs.nixvim.plugins = {
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
          "gi" = "implementation";
          "<leader>h" = "hover";
          "<leader>r" = "rename";
          "<leader>f" = "format";
          "<leader>a" = "code_action";
        };
        silent = true;
      };
      servers = {
        bashls.enable = true;
        #clangd.enable = true; # Why 1 GB of space?
        #java_language_server.enable = true; # 300MB
        #gopls.enable = true; # 300MB
        cmake.enable = true;
        cssls.enable = true;
        html.enable = true;
        zls.enable = true;
        pyright.enable = true;
        texlab.enable = true;
        nil_ls = {
          enable = true;
          settings = {
            formatting.command = [
              (lib.getExe pkgs.nixfmt)
              "--quiet"
            ];
          };
        };
        nixd.enable = true;
      };
    };
  };
}
