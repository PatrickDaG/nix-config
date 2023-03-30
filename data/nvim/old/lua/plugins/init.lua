local fn = vim.fn

-- clone package manager if not existant
local intall_path = fn.stdpath("data").."/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(intall_path)) > 0 then
	fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", intall_path})
	vim.cmd "packadd packer.nvim"
end

local function conf(module)
	return "require('plugins.config." .. module .. "')"
end

return require("packer").startup(function(use)
	--packer managing itself
	use "wbthomason/packer.nvim"


	-- Appereance ---------------------------------------------------
	-- Lelegs -------------------------------------------------------


	--statusline
	use { "nvim-lualine/lualine.nvim",
		requires = {"kyazdani42/nvim-web-devicons", opt = true},
		config = function() require("plugins.config.lualine") end
	}

	--colorscheme
	use { "navarasu/onedark.nvim", config = function() require("plugins.config.onedark") end}

	-- nice line before lines
	use { "lukas-reineke/indent-blankline.nvim", config = conf("indent-blankline")}
	-- make spaces red
	use { "ntpeters/vim-better-whitespace", config = conf("better-whitespace")}

	-- signale für git
	use { "lewis6991/gitsigns.nvim",
		requires = {
			'nvim-lua/plenary.nvim'
		},
		config = function()
			require("gitsigns").setup {
			}
		end
	}

	use { 'kosayoda/nvim-lightbulb', config = conf("lightbulb") }

	-- dressing macht refactoring fenster schöner
	use { 'stevearc/dressing.nvim' }

    -- Language Support ---------------------------------------------
	-- leligs -------------------------------------------------------


	--treesitter
	use {
		"nvim-treesitter/nvim-treesitter",
		event = "BufRead",
		config = conf("treesitter"),
	}

	--sane(I hope) default configs for a number of lsps ------------
	use { "neovim/nvim-lspconfig" }

	use { "ziglang/zig.vim" }

	-- autocomplete wuhu -------------------------------------------
	use {
		"hrsh7th/nvim-cmp",
		requires = { { "hrsh7th/cmp-buffer" },
					 { "hrsh7th/cmp-path" },
					 { "hrsh7th/cmp-cmdline" },
					 { "petertriho/cmp-git" },
					 { "hrsh7th/cmp-calc" },
					 { "hrsh7th/cmp-nvim-lsp" },
					 { "hrsh7th/cmp-nvim-lua" },
					 { "hrsh7th/cmp-emoji" },
					 },
		config = function() require("plugins.config.nvim-cmp") end
	}

	--snippet engine required for nvim cmp
	use { "L3MON4D3/LuaSnip", after = "nvim-cmp" }

	use { "saadparwaiz1/cmp_luasnip", after = "LuaSnip" }

	--additional functionality for nvim cmp
	-- function signature on hover
	use { "ray-x/lsp_signature.nvim", after = "nvim-lspconfig",
			config = function() require("lsp_signature").setup() end }

	--pictograms in lsp completion
	use { "onsails/lspkind-nvim" }

	-- Addons ------------------------------------------------------
	-- Lelugs ------------------------------------------------------


	--file browser

	use {
	"nvim-neo-tree/neo-tree.nvim",
		branch = "v2.x",
		requires = {
		"nvim-lua/plenary.nvim",
		"kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		},
		config = conf("neotree")
	}

	-- window picker to use with neotree
	use {
		's1n7ax/nvim-window-picker',
		tag = 'v1.*',
		config = function()
			require'window-picker'.setup()
		end,
	}

	--startup page
	use {
		"goolord/alpha-nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function() require("plugins.config.alpha") end
		}

	--finder lel
	use {
		 'nvim-telescope/telescope.nvim',
		 requires = { {"nvim-lua/plenary.nvim"},
					  {"nvim-treesitter/nvim-treesitter", opt =true},
					  {"kyazdani42/nvim-web-devicons", opt = true},
					  {"sudormrfbin/cheatsheet.nvim"},
					  {"nvim-telescope/telescope-fzf-native.nvim", run = 'make'} },
		 cmd = "Telescope",
		 config = conf("telescope")
	 }

	 -- make notification
	 use {
		"rcarriga/nvim-notify"
	}

	 -- undo tree weil badly needed
	 use { "simnalamburt/vim-mundo", config = conf("mundo") }

	 -- vim multi cursor witl malze meint es wäre gut
	 use { "mg979/vim-visual-multi", config = conf("vim-visual-multi") }
	 -- git in vim für die die es brauchen
	 use { "tpope/vim-fugitive" }

	 -- Plugins for editing wuhu

	 -- Surround shit pls
	 use { "tpope/vim-surround" }

	-- Commenting
	use { "numToStr/Comment.nvim", config = conf("comment") }

	-- align thing according to shit
	use { "junegunn/vim-easy-align" }


	-- gpg edit in vim
	use { "jamessan/vim-gnupg"}


end)


