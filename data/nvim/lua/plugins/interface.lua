return {
	-- colorscheme
	{
		"navarasu/onedark.nvim",
		init = function()
			require("onedark").load()
		end,
	},
	-- statusline
	{
		'nvim-lualine/lualine.nvim',
		dependencies = {
			"kyazdani42/nvim-web-devicons",
		},
		opts = {
			options = {
				theme = "auto"
			},
			extensions = {
				"nvim-tree",
				"quickfix",
			},
		},
	},
	-- show indent
	{
		"lukas-reineke/indent-blankline.nvim",
		opts = {
			buftype_exclude = { "help", "terminal", "nofile"},
			filetype_exclude = { "terminal", "lsp-info"},
		},
	},
	-- show trailing whitspaces
	{
		"ntpeters/vim-better-whitespace",
		init = function()
			local map = vim.keymap.set
			local opts = {noremap = true, silent = true}

			function _G.whitespace_visibility()
				if vim.api.nvim_eval("&buftype") == "nofile" then
					vim.cmd('execute "DisableWhitespace"')
				else
					vim.cmd('execute "EnableWhitespace"')
				end
			end

			vim.cmd("autocmd BufEnter * lua whitespace_visibility()")

			-- Strip whitespace
			map('n', '<leader>$', ':StripWhitespace<CR>', opts)
		end,
	},
	-- signale für git
	{
		"lewis6991/gitsigns.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim"
		},
		config = true,
	},
	-- bischen vim salat
	-- macht refactoring popups schöner
	{
		"stevearc/dressing.nvim"
	},
}
