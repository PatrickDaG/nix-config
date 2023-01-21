local present, cmp = pcall(require, "cmp")
if not present then
    return
end
local lspkind = require('lspkind')

function format(opts)
	if opts == nil then
		opts = {}
	end

	return function(entry, vim_item)
		vim_item.kind = lspkind.symbolic(vim_item.kind, opts)

		if opts.menu ~= nil then
			vim_item.menu = opts.menu[entry.source.name]
		end

		if entry.source.name == 'cmp_tabnine' then
			if entry.completion_item.data ~= nil and entry.completion_item.data.detail ~= nil then
				vim_item.menu = entry.completion_item.data.detail .. ' ' .. vim_item.menu
			end
			vim_item.kind = ''
		end

		if opts.maxwidth ~= nil then
			vim_item.abbr = string.sub(vim_item.abbr, 1, opts.maxwidth)
		end

		return vim_item
	end
end

cmp.setup({
	-- Integrate luasnip
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end,
	},
	-- Add pictograms from lspkind
	formatting = {
		format = format({
			with_text = false,
			maxwidth = 50,
			menu = {
				buffer = "[Buf]",
				calc = "[Calc]",
				cmp_git = "[Git]",
				cmp_tabnine = "[TN]",
				emoji = "[Emoji]",
				luasnip = "[Snip]",
				nvim_lsp = "[LSP]",
				nvim_lua = "[Lua]",
				path = "[Path]",
			}
		})
	},
  mapping = {
    ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c'}),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c'}),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c'}),
    ['<C-e>'] = cmp.mapping(cmp.mapping.close(), { 'i', 'c'} ),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ["<Tab>"] = function(fallback)
      if cmp.visible() then
         cmp.select_next_item()
      elseif require("luasnip").expand_or_jumpable() then
         vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
      else
         fallback()
      end
    end,
    ["<S-Tab>"] = function(fallback)
      if cmp.visible() then
         cmp.select_prev_item()
      elseif require("luasnip").jumpable(-1) then
         vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
      else
         fallback()
      end
    end,
  },
  sources = {
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
	{ name = 'cmp_git' },
	{ name = 'emoji' },
	{ name = 'calc' },
	{ name = 'cmp_tabnine' },
  }
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = {
    { name = 'path' },
    { name = 'cmdline' }
  }
})
-- language servers
local sumneko_root_path = vim.fn.stdpath("data").."/lua-language-server"
local sumneko_binary = sumneko_root_path.."/bin/lua-language-server"

require("lspconfig").sumneko_lua.setup {    -- lua:    https://github.com/sumneko/lua-language-server
	cmd = { sumneko_binary, "-E", sumneko_root_path .. "/main.lua" },
	settings = {
		Lua = {
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = {'vim'},
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = { enable = false, },
		},
	},
}

require('lspconfig').clangd.setup {}        --needs clang
require('lspconfig').rust_analyzer.setup {}      --still needs rust analyzer installed
require('lspconfig').bashls.setup {}  --needs bash-language-server from npm
require('lspconfig').cmake.setup {} --still needs cmake language servers
require('lspconfig').html.setup {} --needs npm vscode-langservers-extracted
require('lspconfig').hls.setup {} --still needs github: haskell-language-server
-- maybe use jdtls ??? require('lspconfig').java_language_server.setup {} --still needs github java-language-server
require('lspconfig').pyright.setup {} -- needs npm pyright
require('lspconfig').texlab.setup {} -- needs github texlab
require'lspconfig'.gopls.setup{} -- needs gopls installed
require'lspconfig'.zls.setup{}
