# dependencies: wcurl
PRS=("353272" "353230")

if [ ! -f flake.nix ]; then
	echo "Not in a flake top level"
	exit 1
fi

mkdir -p patches
echo "Removing old patches"
rm patches/*.diff
for t in "${PRS[@]}"; do
	echo "Fetching PR #$t"
	url="https://github.com/NixOS/nixpkgs/pull/$t"
	echo "$url"
	wcurl "$url.diff" --curl-options "--output-dir patches"
done
