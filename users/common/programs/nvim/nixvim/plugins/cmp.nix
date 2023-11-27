{
  programs.nixvim.plugins = {
    luasnip = {
      enable = true;
      extraConfig = {
        history = true;
        # Update dynamic snippets while typing
        updateevents = "TextChanged,TextChangedI";
        enable_autosnippets = true;
      };
    };

    cmp_luasnip.enable = true;
    cmp-cmdline.enable = true;
    cmp-cmdline-history.enable = true;
    cmp-path.enable = true;
    cmp-emoji.enable = true;
    cmp-treesitter.enable = true;
    cmp-nvim-lsp.enable = true;
    cmp-nvim-lsp-document-symbol.enable = true;
    cmp-nvim-lsp-signature-help.enable = true;
    nvim-cmp = {
      enable = true;
      sources = [
        {name = "luasnip";}
        {name = "nvim_lsp_signature_help";}
        {name = "nvim_lsp";}
        {name = "buffer";}
        {name = "async_path";}
        {name = "calc";}
        {name = "emoji";}
        {name = "nvim_lua";}
      ];
      snippet.expand = "luasnip";
      formatting.fields = ["abbr" "kind" "menu"];
      formatting.format = ''
        function(_, vim_item)
        local icons = {
          Namespace = "󰌗",
          Text = "󰉿",
          Method = "󰆧",
          Function = "󰆧",
          Constructor = "",
          Field = "󰜢",
          Variable = "󰀫",
          Class = "󰠱",
          Interface = "",
          Module = "",
          Property = "󰜢",
          Unit = "󰑭",
          Value = "󰎠",
          Enum = "",
          Keyword = "󰌋",
          Snippet = "",
          Color = "󰏘",
          File = "󰈚",
          Reference = "󰈇",
          Folder = "󰉋",
          EnumMember = "",
          Constant = "󰏿",
          Struct = "󰙅",
          Event = "",
          Operator = "󰆕",
          TypeParameter = "󰊄",
          Table = "",
          Object = "󰅩",
          Tag = "",
          Array = "󰅪",
          Boolean = "",
          Number = "",
          Null = "󰟢",
          String = "󰉿",
          Calendar = "",
          Watch = "󰥔",
          Package = "",
          Copilot = "",
          Codeium = "",
          TabNine = "",
        }
        vim_item.kind = string.format("%s %s", icons[vim_item.kind], vim_item.kind)
        return vim_item
        end
      '';
      mapping = {
        "<CR>" = "cmp.mapping.confirm({ select = false })";
        "<C-Space>" = "cmp.mapping(cmp.mapping.complete(), { \"i\", \"c\" })";
        "<Tab>".action = ''
          function(fallback)
          	if cmp.visible() then
          		cmp.select_next_item()
          	elseif require("luasnip").expand_or_jumpable() then
          		vim.fn.feedkeys(
          			vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true),
          			""
          		)
          	else
          		fallback()
          	end
          end
        '';
        "<S-Tab>".action = ''          function(fallback)
          						if cmp.visible() then
          							cmp.select_prev_item()
          						elseif require("luasnip").jumpable(-1) then
          							vim.fn.feedkeys(
          								vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true),
          								""
          							)
          						else
          							fallback()
          						end
          					end
        '';
      };
    };
  };
}
