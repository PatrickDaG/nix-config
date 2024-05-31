{
  writeShellApplication,
  ps,
  procps,
  xdotool,
}:
writeShellApplication {
  name = "clone-term";
  runtimeInputs = [ps procps xdotool];
  text = ''

    PAREN=$(xdotool getwindowfocus getwindowpid)

    MAXDEPTH=0
    SELECTED=0

    function recurse() {
      #shellcheck disable=SC2207
    	for i in $(pgrep -P "$1"); do

    		if [[ "$(readlink -e "/proc/''${i}/exe")" == *"zsh"* ]] && [[ $2 -gt $MAXDEPTH ]]; then
    			SELECTED="$i"
    			MAXDEPTH="$2"
    		fi
    		recurse "$i" "$(( $2 + 1 ))"
    	done
    }

    recurse "$PAREN" 1

    if [[ $SELECTED == 0 ]]; then
    	echo "not zsh found"
    	exit 1
    fi

    # kitty should be from user env
    kitty --detach -d "$(readlink "/proc/''${SELECTED}/cwd")"
  '';
}
