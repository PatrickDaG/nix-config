{
  hm.programs.nixvim.plugins = {
    blink-compat.enable = true;
    blink-cmp = {
      enable = true;
      settings = {
        keymap = {
          preset = "none";
          "<A-Tab>" = [
            "snippet_forward"
            "fallback"
          ];
          "<A-S-Tab>" = [
            "snippet_backward"
            "fallback"
          ];
          "<Tab>" = [
            "select_next"
            "fallback"
          ];
          "<S-Tab>" = [
            "select_prev"
            "fallback"
          ];
        };
        appearance = {
          use_nvim_cmp_as_default = true;
          nerd_font_variant = "mono";
        };
        sources = {
          default = [
            "lsp"
            "path"
            "snippets"
            "emoji"
            "buffer"
          ];
          providers = {
            emoji = {
              name = "emoji";
              module = "blink.compat.source";
            };
          };
        };
        signature.enabled = true;
        completion = {
          list.selection = "auto_insert";
          #   menu = {
          #     border = "none";
          #     draw = {
          #       gap = 1;
          #       treesitter = [ "lsp" ];
          #       columns = [
          #         {
          #           __unkeyed-1 = "label";
          #         }
          #         {
          #           __unkeyed-1 = "kind_icon";
          #           __unkeyed-2 = "kind";
          #           gap = 1;
          #         }
          #         { __unkeyed-1 = "source_name"; }
          #       ];
          #     };
          #   };
          #   trigger = {
          #     show_in_snippet = false;
          #   };
          documentation = {
            auto_show = true;
            #     window = {
            #       border = "rounded";
            #     };
          };
          #   accept = {
          #     auto_brackets = {
          #       enabled = true;
          #     };
          #   };
        };
      };
    };
    cmp-emoji.enable = true;
    lsp.capabilities = # lua
      ''
        capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)
      '';

  };
}
