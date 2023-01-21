local A = require('plugins.utils.alpha')
local images = require("plugins.data.alpha")
math.randomseed(os.time())
local header = images[math.random(#images)]

local separator = '╼═╾────────────────────────────────────────────╼═╾'

require('alpha').setup {
	layout = {
		A.pad(2), A.text(header, 'Type'),
		A.pad(2), A.text(separator, 'Number'),
		A.pad(1), A.buttons {
			A.button("e", "  New file",       ":enew<CR>"),
		},
		A.pad(2), A.buttons {
			A.button("u", "  Update plugins", ":PackerSync<CR>"),
			A.button("c", "  Check health",   ":checkhealth<CR>"),
			A.button("q", "  Quit",           ":qa<CR>"),
		},
		A.text(separator, 'Number'),
	},
	opts = { margin = 5 },
}
