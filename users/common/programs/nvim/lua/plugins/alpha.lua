local images = require("data.alpha")
math.randomseed(os.time())
local header = images[math.random(#images)]
local if_nil = vim.F.if_nil
local separator =
	"╼═╾────────────────────────────────────────────╼═╾"

local button = function(shortcut, txt, keybind, keybind_opts)
	local opts = {
		position = "center",
		shortcut = shortcut,
		cursor = 5,
		width = 50,
		align_shortcut = "right",
		hl_shortcut = "Keyword",
	}

	if keybind then
		keybind_opts = if_nil(keybind_opts, { noremap = true, silent = true })
		opts.keymap = { "n", shortcut, keybind, keybind_opts }
	end

	local function on_press()
		local key = vim.api.nvim_replace_termcodes(shortcut .. "<Ignore>", true, false, true)
		vim.api.nvim_feedkeys(key, "normal", false)
	end

	return {
		type = "button",
		val = txt,
		on_press = on_press,
		opts = opts,
	}
end

local buttons = function(xs, spacing)
	return {
		type = "group",
		val = xs,
		opts = { spacing = if_nil(spacing, 1) },
	}
end

local text = function(value, hl)
	return {
		type = "text",
		val = value,
		opts = {
			position = "center",
			hl = hl,
		},
	}
end

local pad = function(lines)
	return { type = "padding", val = lines }
end
return {
	{
		"goolord/alpha-nvim",
		dependencies = {
			"kyazdani42/nvim-web-devicons",
		},
		opts = {
			layout = {
				pad(2),
				text(header, "Type"),
				pad(2),
				text(separator, "Number"),
				pad(1),
				buttons({
					button("e", "  New file", ":enew<CR>"),
				}),
				pad(2),
				buttons({
					button("u", "  Check Plugins", ":Lazy<CR>"),
					button("c", "  Check health", ":checkhealth<CR>"),
					button("q", "󰗼  Quit", ":qa<CR>"),
				}),
				text(separator, "Number"),
			},
			opts = { margin = 5 },
		},
	},
}
