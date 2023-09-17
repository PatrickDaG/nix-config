alias l = ls -a

$env.config = {
	show_banner: false
	completions: {
		quick: true # Complete last element automatically
		partial: true # Start with partial completion
		algorithm: "fuzzy"
		external: {
			enable: true
			max_results: 250
		}
	}
	history: {
		max_size: 1000001
		sync_on_enter: true # write history after every command
		isolation: true # Only sync on session end, keep terminals separated
		file_format: "sqlite"
	}

	table: {
		mode: "heavy"
	}
	cd: {
		abbreviations: true
	}
	shell_integration: true
}
