{ pkgs, inputs }:
let
  jail = inputs.jail-nix.lib.init pkgs;
in
{
  inherit jail;
  baseCombinators = with jail.combinators; [
    network
    time-zone
    no-new-session
    (readonly (noescape "\"$PWD/../\""))

    mount-cwd

    # Nix support: expose the full nix store (read-only),
    # the daemon socket, and caches so nix builds work inside the sandbox.
    (readonly "/nix/store")
    (readwrite "/nix/var/nix/daemon-socket")
    # noescape needed to expand ~
    (try-readwrite (noescape "~/.cache/nix"))
    (readonly "/etc/nix")
    (readonly "/etc/static/nix")
    (try-fwd-env "NIX_PATH")
    (set-env "NIX_REMOTE" "daemon")

    # Allow jujutsu usage
    (readonly (noescape "~/.config/jj"))
    (readwrite (noescape "\"$PWD/../.jj\""))
    (readwrite (noescape "\"$PWD/../.git\""))

    # GitHub CLI auth for PR interactions (separate account from host)
    # Uses ~/.config/gh-pi so the sandbox gets its own gh identity.
    (readwrite (noescape "~/.config/gh-pi"))
    (set-env "GH_CONFIG_DIR" (noescape "~/.config/gh-pi"))

    # Spawn agent in a new jj workspace
    # Just don't spawn 2 agent in the same second. Thx
    (add-runtime ''
      date=$(date +"%Y-%m-%dT%H:%M:%S")
      export AGENT_SESSION_NAME="agent-$date"
      jj workspace add "$AGENT_SESSION_NAME" --quiet
      cd "$AGENT_SESSION_NAME"
      jj describe -m "agent session $date" --quiet
    '')
    (add-cleanup ''
      if [ -n "$AGENT_SESSION_NAME" ]; then
        # Capture change id while still in the workspace directory
        change_id=$(jj log --no-graph -r @ -T 'change_id')
        is_empty=$(jj log --no-graph -r @ -T 'if(empty, "true", "false")')
        cd ..
        jj workspace forget "$AGENT_SESSION_NAME" --quiet
        # Abandon the changeset if it is empty
        if [ "$is_empty" = "true" ]; then
          jj abandon "$change_id" --quiet
        fi
        rm -r "$AGENT_SESSION_NAME"
      fi
    '')

    (add-pkg-deps (
      with pkgs;
      [
        # keep-sorted start
        bashInteractive
        curl
        diffutils
        findutils
        gawkInteractive
        gh
        git
        gnugrep
        gnutar
        gzip
        jq
        jujutsu
        nix
        nixpkgs-review
        ripgrep
        ps
        python3
        ripgrep
        unzip
        which
        # keep-sorted end
      ]
    ))
  ];
}
