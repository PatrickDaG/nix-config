local M = {}
local if_nil = vim.F.if_nil

M.button = function(shortcut, txt, keybind, keybind_opts)
	local opts = {
		position = "center",
		shortcut = shortcut,
		cursor = 5,
		width = 50,
		align_shortcut = "right",
		hl_shortcut = "Keyword",
	}

	if keybind then
		keybind_opts = if_nil(keybind_opts, {noremap = true, silent = true})
		opts.keymap = { "n", shortcut, keybind, keybind_opts }
	end

	local function on_press()
		local key = vim.api.nvim_replace_termcodes(shortcut .. '<Ignore>', true, false, true)
		vim.api.nvim_feedkeys(key, "normal", false)
	end

	return {
		type = "button",
		val = txt,
		on_press = on_press,
		opts = opts,
	}
end

M.buttons = function(xs, spacing)
	return {
		type = "group",
		val = xs,
		opts = { spacing = if_nil(spacing, 1) }
	}
end

M.text = function(value, hl)
	return {
		type = "text",
		val = value,
		opts = {
			position = "center",
			hl = hl,
		}
	}
end

M.pad = function(lines)
	return { type = "padding", val = lines }
end

return M
