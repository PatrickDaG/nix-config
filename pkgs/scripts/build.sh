set -euo pipefail

function die {
	echo "error: $*" >&2
	exit 1
}
function show_help() {
	echo ' Usage: build [OPTIONS] <host,...>'
	echo 'Build the toplevel nixos configuration for hosts'
}

USER_FLAKE_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd) ||
	die "Could not determine current directory"

cd "$USER_FLAKE_DIR"

[[ $# -gt 0 ]] || {
	show_help
	exit 1
}

OPTIONS=()
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
	case "$1" in
	"help" | "--help" | "-h")
		show_help
		exit 1
		;;
	-*)
		OPTIONS+=("$1")
		;;
	*)
		POSITIONAL_ARGS+=("$1")
		;;
	esac
	shift
done

[[ ! ${#POSITIONAL_ARGS[@]} -lt 1 ]] ||
	die "Missing argument: <hosts,...>"
[[ ! ${#POSITIONAL_ARGS[@]} -gt 1 ]] ||
	die "Too many arguments"

shopt -s lastpipe
tr , '\n' <<<"${POSITIONAL_ARGS[0]}" | sort -u | readarray -t HOSTS

NIXOS_CONFIGS=()
for host in "${HOSTS[@]}"; do
	NIXOS_CONFIGS+=(".#nixosConfigurations.$host.config.system.build.toplevel")
done

echo -e "Building toplevels for \033[0;32m${#HOSTS[*]} hosts\033[0m"
nom build --print-out-paths --no-link "${OPTIONS[@]}" "${NIXOS_CONFIGS[@]}" ||
	die "Failed building derivations"
