#!/usr/bin/env bash

set -euo pipefail

print_out_path=false
if [[ "$1" == "--print-out-path" ]]; then
  print_out_path=true
  shift
fi

file="$1"
shift
identities=("$@")

# Strip .age suffix, and store path prefix or ./ if applicable
basename="${file%".age"}"
[[ "$file" == "/nix/store/"* ]] && basename="${basename#*"-"}"
[[ "$file" == "./"* ]] && basename="${basename#"./"}"

# Calculate a unique content-based identifier (relocations of
# the source file in the nix store should not affect caching)
new_name="$(sha512sum "$file")"
new_name="${new_name:0:32}-${basename//"/"/"%"}"

# Derive the path where the decrypted file will be stored
out="/var/tmp/nix-import-encrypted/$new_name"

# Decrypt only if necessary
if [[ ! -e "$out" ]]; then
  if [[ "${NIX_IMPORT_ENCRYPTED_CACHE_ONLY:-0}" == "1" ]]; then
    printf 'Missing cached decrypted output for %s: %s\nPopulate the cache outside the coding-agent sandbox first.\n' "$file" "$out" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$out")"
  args=()
  for i in "${identities[@]}"; do
    args+=("-i" "$i")
  done
  rage -d "${args[@]}" -o "$out" "$file"
fi

# Print out path or decrypted content
if [[ "$print_out_path" == true ]]; then
	echo "$out"
else
	cat "$out"
fi
