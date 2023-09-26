{
  stdenv,
  symlinkJoin,
  writeShellApplication,
}: let
  deploy = writeShellApplication {
    name = "deploy";
    text = ''
          	set -euo pipefail

          function die { echo "error: $*" >&2; exit 1;}
          function show_help() {
          	echo ' Usage: deploy [OPTIONS] <host,...> [ACTION]'
          	echo 'ACTION:'
          	echo '  switch			[default] build, push and switch to the new configuration'
          	echo '  boot			switch on next boot'
          	echo '  test			switch to config but do not make it the boot default'
          	echo '  dry-activate	just show what an activation would do'
          	echo ""
          	echo 'OPTIONS:'
          	echo '  --help		show this help menu'
          }

          	USER_FLAKE_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd) \
          || die "Could not determine current directory"

          cd "$USER_FLAKE_DIR"

          [[ $# -gt 0 ]] || {
          	show_help
          	exit 1
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
          	esac
          	shift
          done

          [[ ! ''${#POSITIONAL_ARGS[@]} -lt 1 ]] \
          || die "Missing argument: <hosts,...>"
          [[ ! ''${#POSITIONAL_ARGS[@]} -gt 2 ]] \
          || die "Too many arguments"

          shopt -s lastpipe
          tr , '\n' <<< "''${POSITIONAL_ARGS[0]}" | sort -u | readarray -t HOSTS

          ACTION="''${POSITIONAL_ARGS[1]-switch}"

          function main() {
          	local config
          	config=".#nixosConfigurations.$1.config.system.build.toplevel"
          	local top_level
              top_level=$(nix build --no-link --print-out-paths "''${OPTIONS[@]}" "$config" 2>/dev/null)

          	echo -e "Copying toplevel for \033[0;32m$1\033[0m"
              nix copy --to "ssh://$1" "$top_level" \
          	|| die "Failed copying closure to $1"

          	echo -e "Applying toplevel for \033[0;32m$1\033[0m"
      (
      exec > >(trap "" INT TERM; sed "s/^/[0;32m$1:[0m /")
      exec 2> >(trap "" INT TERM; sed "s/^/[0;32m$1:[0m /" >&2)
          	ssh "$1" -- /run/current-system/sw/bin/nix-env --profile /nix/var/nix/profiles/system --set "$top_level" \
          	|| die "Error registering toplevel$1"
          	ssh "$1" -- "$top_level/bin/switch-to-configuration" "$ACTION" \
          	|| die "Error activating toplevel for $1"
      )
          }

          NIXOS_CONFIGS=()
          for host in "''${HOSTS[@]}"; do
          	NIXOS_CONFIGS+=(".#nixosConfigurations.$host.config.system.build.toplevel")
          done
          echo -e "Building toplevels for \033[0;32m''${#HOSTS[*]} hosts\033[0m"
          nix build --no-link "''${OPTIONS[@]}" "''${NIXOS_CONFIGS[@]}" \
          || die "Failed building derivations"

          for host in "''${HOSTS[@]}"; do
          	main "$host" &
          done
          wait
    '';
  };
  build = writeShellApplication {
    name = "build";
    text = ''
      	set -euo pipefail

      function die { echo "error: $*" >&2; exit 1;}
      function show_help() {
      	echo ' Usage: build [OPTIONS] <host,...>'
      	echo 'Build the toplevel nixos configuration for hosts'
      }

      	USER_FLAKE_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd) \
      || die "Could not determine current directory"

      cd "$USER_FLAKE_DIR"

      [[ $# -gt 0 ]] || {
      	show_help
      	exit 1
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
      || die "Missing argument: <hosts,...>"
      [[ ! ''${#POSITIONAL_ARGS[@]} -gt 1 ]] \
      || die "Too many arguments"

      shopt -s lastpipe
      tr , '\n' <<< "''${POSITIONAL_ARGS[0]}" | sort -u | readarray -t HOSTS

      NIXOS_CONFIGS=()
      for host in "''${HOSTS[@]}"; do
      	NIXOS_CONFIGS+=(".#nixosConfigurations.$host.config.system.build.toplevel")
      done


      echo -e "Building toplevels for \033[0;32m''${#HOSTS[*]} hosts\033[0m"
      nix build --print-out-paths --no-link "''${OPTIONS[@]}" "''${NIXOS_CONFIGS[@]}" \
      || die "Failed building derivations"

    '';
  };
in
  symlinkJoin {
    name = "deploy and build";
    paths = [deploy build];
  }
