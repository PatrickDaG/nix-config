set -euo pipefail

function die {
  echo "error: $*" >&2
  exit 1
}
function show_help() {
  echo ' Usage: deploy [OPTIONS] <system[@host],...> [ACTION]'
  echo ' Deploy a system as defined in the current flakes nixosSystem'
  echo ' If host is not given use the system name as host'
  echo ""
  echo 'ACTION:'
  echo '  switch			[default] build, push and switch to the new configuration'
  echo '  boot			switch on next boot'
  echo '  test			switch to config but do not make it the boot default'
  echo '  dry-activate	just show what an activation would do'
  echo ""
  echo 'OPTIONS:'
  echo '  --help		show this help menu'
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
[[ ! ${#POSITIONAL_ARGS[@]} -gt 2 ]] ||
die "Too many arguments"

shopt -s lastpipe
tr , '\n' <<<"${POSITIONAL_ARGS[0]}" | sort -u | readarray -t HOSTS

ACTION="${POSITIONAL_ARGS[1]-switch}"

function main() {
  local system
  local host
  if [[ $1 == *"@"* ]]; then
    arr=()
    echo -n "$1" | readarray -d "@" -t arr
    system="${arr[0]}"
    host="root@${arr[1]}"
  else
    system=$1
    host=$system
  fi
  local config
  config=".#nixosConfigurations.$system.config.system.build.toplevel"
  local top_level
  exec > >(
    trap "" INT TERM
    sed "s/^/[0;32m$system:[0m /"
  )
  exec 2> >(
    trap "" INT TERM
    sed "s/^/[0;32m$system:[0m /" >&2
  )
  top_level=$(nix build --no-link --print-out-paths "${OPTIONS[@]}" "$config" || die "Failed building derivation for $system")

  echo -e "Copying toplevel for \033[0;32m$system\033[0m"
  nix copy --to "ssh://$host" "$top_level" ||
  die "Failed copying closure to $system"

  echo -e "Applying toplevel for \033[0;32m$system\033[0m"
  (
    prev_system=$(ssh "$host" -- readlink -e /nix/var/nix/profiles/system)
    ssh "$host" -- /run/current-system/sw/bin/nix-env --profile /nix/var/nix/profiles/system --set "$top_level" ||
    die "Error registering toplevel $system"
    ssh "$host" -- "$top_level/bin/switch-to-configuration" "$ACTION" ||
    die "Error activating toplevel for $system"
    if [[ -n "$prev_system" ]]; then
      ssh "$host" -- nvd --color always diff "$prev_system" "$top_level"
    fi
  )
}

echo -e "Building toplevels for \033[0;32m${#HOSTS[*]} hosts\033[0m"

for host in "${HOSTS[@]}"; do
  main "$host" &
done
wait
