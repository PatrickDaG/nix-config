local format = function(opts)
	if opts == nil then
		opts = {}
	end

	return function(entry, vim_item)
		vim_item.kind = require("lspkind").symbolic(vim_item.kind, opts)

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

-- this file contains lsp and tree-sitter related config
return {
	-- bischen baumsitzen wuhu
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			ensure_installed = "all",
			highlight = {
				enable = true,
			},
			indent = {
				enable = true,
			},
		},
		main = "nvim-treesitter.configs",
	},
	-- manage and install lsp servers, linters and formatters
	-- This sadly does not work correctly with nix
	-- the installed lsp servers would need to be patchelf'd
	-- in most cases
	-- This might be fixable. but that's for another day
	--{
	--	"williamboman/mason.nvim",
	--	build = ":MasonUpdate", -- :MasonUpdate updates registry contents
	--	config = true,
	--},
	---- bridge the gap between mason and lspconfig
	--{
	--	"williamboman/mason-lspconfig.nvim",
	--	opts = {
	--		ensure_installed = { "nil_ls", },
	--	},
	--	init = function()
	--		require("mason-lspconfig").setup_handlers {
	--			function (server_name)
	--				require("lspconfig")[server_name].setup {}
	--			end,
	--		}
	--	end,
	--},
	-- lsp
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			lspconfig.bashls.setup { capabilities = capabilities, }
			lspconfig.clangd.setup { capabilities = capabilities, }
			lspconfig.cmake.setup { capabilities = capabilities, }
			lspconfig.gopls.setup { capabilities = capabilities, }
			lspconfig.hls.setup { capabilities = capabilities, }
			lspconfig.lua_ls.setup { capabilities = capabilities, }
			lspconfig.texlab.setup { capabilities = capabilities, }
			lspconfig.nil_ls.setup { capabilities = capabilities, }
			lspconfig.pyright.setup { capabilities = capabilities, }
			lspconfig.rust_analyzer.setup { capabilities = capabilities, }
			lspconfig.zls.setup { capabilities = capabilities, }
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"FelipeLema/cmp-async-path",
			"hrsh7th/cmp-calc",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-emoji",

			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",

			"onsails/lspkind-nvim",
			{
				"ray-x/lsp_signature.nvim",
				config = true,
			},
			{
				'tzachar/cmp-tabnine',
				build = './install.sh',
			},
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				sources = {
					{ name = 'luasnip' },
					{ name = 'cmp_tabnine' },
					{ name = 'nvim_lsp_signature_help' },
					{ name = 'nvim_lsp' },
					{ name = 'buffer' },
					{ name = 'async_path' },
					{ name = 'calc' },
					{ name = 'emoji' },
					{ name = 'nvim_lua' },
				},
				snippet = {
					expand = function(args)
						require('luasnip').lsp_expand(args.body)
					end,
				},
				-- add lspkind pictograms
				formatting = {
					format = format({
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
					}),
				},
				mapping = {
					['<CR>'] = cmp.mapping.confirm({ select = false }),
					['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c'}),
					["<Tab>"] = require("cmp").mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif require("luasnip").expand_or_jumpable() then
							vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
						else
							fallback()
						end
					end),
					["<S-Tab>"] = require("cmp").mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif require("luasnip").jumpable(-1) then
							vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
						else
							fallback()
						end
					end),
				},
			})
		end,
		init = function()
			local cmp = require("cmp")
			-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline({ '/', '?'}, {
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
		end,
	},
}
