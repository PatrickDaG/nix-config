{writeShellApplication}:
writeShellApplication {
  name = "minify";
  text = ''
                	set -euo pipefail
    function die { echo "error: $*" >&2; exit 1;}
    function print_help() {
    echo ' Usage: minify <flake> [OPTION]'
    }

     OPTIONS=()
     POSITIONAL_ARGS=()
     while [[ $# -gt 0 ]]; do
     case "$1" in
     	"help"|"--help"|"-h")
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

     [[ ! ''${#POSITIONAL_ARGS[@]} -lt 1 ]] \
     || die "Missing argument: <flake>"
     [[ ! ''${#POSITIONAL_ARGS[@]} -gt 2 ]] \
     || die "Too many arguments"

    path=$(realpath "''${POSITIONAL_ARGS[0]}")
    nix eval --impure --argstr path "$path" --file ${./minify.nix} "erg"
  '';
}
