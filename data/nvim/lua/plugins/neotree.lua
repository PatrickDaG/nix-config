local notify = function(message, level)
 vim.notify(message, level, { title = "NeoTree" })
end
return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = 'v2.x',
		dependencies = {
			"nvim-lua/plenary.nvim",
			"kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			{
				"s1n7ax/nvim-window-picker",
				config = function()
					require("window-picker").setup()
				end,
			},
			{
				"rcarriga/nvim-notify",
				init = function()
					vim.notify = require("notify")
				end,
			},
		},

		init = function()
			vim.cmd [[let g:neo_tree_remove_legacy_commands = 1]]
		end,
		keys = {
		      { "<leader>t", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
	      },
		opts = {
			 sort_case_insensitive = true,
			 use_popups_for_input = false,
			 popup_border_style = "rounded",
			 win_options = {
				 winblend = 0,
			 },
			 default_component_configs = {
				 modified = {
					 symbol = "~ ",
				 },
				 indent = {
					 with_expanders = true,
				 },
				 name = {
					 trailing_slash = true,
				 },
				 git_status = {
					 symbols = {
						 added = "+",
						 deleted = "✖",
						 modified = "",
						 renamed = "➜",
						 untracked = "?",
						 ignored = "",
						 unstaged = "",
						 staged = "",
						 conflict = "",
					 },
				 },
			 },
			 window = {
				 width = 34,
				 position = "left",
				 mappings = {
					 ["<CR>"] = "open_with_window_picker",
					 ["s"] = "split_with_window_picker",
					 ["v"] = "vsplit_with_window_picker",
					 ["t"] = "open_tabnew",
					 ["z"] = "close_all_nodes",
					 ["Z"] = "expand_all_nodes",
					 ["a"] = { "add", config = { show_path = "relative" } },
					 ["A"] = { "add_directory", config = { show_path = "relative" } },
					 ["c"] = { "copy", config = { show_path = "relative" } },
					 ["m"] = { "move", config = { show_path = "relative" } },
				 },
			 },
			 filesystem = {
				 window = {
					 mappings = {
						 ["gA"] = "git_add_all",
						 ["ga"] = "git_add_file",
						 ["gu"] = "git_unstage_file",
					 },
				 },
				 group_empty_dirs = true,
				 follow_current_file = true,
				 use_libuv_file_watcher = true,
				 filtered_items = {
					 hide_dotfiles = false,
					 hide_by_name = { ".git" },
				 },
			 },
			 event_handlers = {
				 {
					 event = "file_added",
					 handler = function(arg)
						 notify("Added: " .. arg, "info")
					 end,
				 },
				 {
					 event = "file_deleted",
					 handler = function(arg)
						 notify("Deleted: " .. arg, "info")
					 end,
				 },
				 {
					 event = "file_renamed",
					 handler = function(args)
						 notify("Renamed: " .. args.source .. " -> " .. args.destination, "info")
					 end,
				 },
				 {
					 event = "file_moved",
					 handler = function(args)
						 notify("Moved: " .. args.source .. " -> " .. args.destination, "info")
					 end,
				 },
			 },
		 },
	},
}
