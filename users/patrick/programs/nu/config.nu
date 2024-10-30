alias l = ls -a

$env.config = {
	show_banner: false
	completions: {
		quick: true # Complete last element automatically
		partial: true # Start with partial completion
		algorithm: "prefix"
		external: {
			enable: true
			max_results: 250
		}
	}
	history: {
		max_size: 1000001
		sync_on_enter: true # write history after every command
		isolation: true # Only sync on session end, keep terminals separated
		# if isolation is false nushell does not save the session id
		file_format: "sqlite"
	}

	table: {
		mode: "heavy"
	}
	cd: {
		abbreviations: true
	}
	shell_integration: true
	keybindings: [
		{
			name: fuzzy_history
			modifier: control
			keycode: char_r
			mode: [emacs, vi_normal, vi_insert]
			event: [
				{
				send: ExecuteHostCommand
				cmd: "commandline (
					history
					| each { |it| $it.command }
					| uniq
					| reverse
					| str join (char -i 0)
					| fzf --read0 --layout=reverse --select-1 --cycle --height=40%
					  --bind=tab:down,btab:up,ctrl-space:select
					  --query (commandline)
					| decode utf-8
					| str trim
				)"
				}
			]
		}
		{
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
	]
}
