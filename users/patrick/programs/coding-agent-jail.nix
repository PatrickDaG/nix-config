{
  pkgs,
  lib,
  inputs,
}:
let
  jail = inputs.jail-nix.lib.init pkgs;
in
{
  inherit jail;
  baseCombinators = with jail.combinators; [
    network
    time-zone
    no-new-session

    # Support executable scripts with #!/usr/bin/env interpreters.
    (ro-bind "${pkgs.coreutils}/bin/env" "/usr/bin/env")

    # Nix support: expose the full nix store (read-only),
    # the daemon socket, and caches so nix builds work inside the sandbox.
    (readonly "/nix/store")
    (readwrite "/nix/var/nix/daemon-socket")
    # Allow building my config from within the sandbox
    (readonly "/var/tmp/agenix-rekey/")
    (readonly "/var/tmp/nix-import-encrypted/")
    (set-env "NIX_IMPORT_ENCRYPTED_CACHE_ONLY" "1")
    (set-env "NIM_UNLOCK_BUILDERS" "no")
    # noescape needed to expand ~
    (try-readwrite (noescape "~/.cache/nix"))
    (readonly "/etc/nix")
    (readonly "/etc/static/nix")
    (try-fwd-env "NIX_PATH")
    (set-env "NIX_REMOTE" "daemon")

    # Keep direnv approval state inside the jail, separate from host approvals.
    (write-text (noescape "~/.config/direnv/direnvrc") ''
      source ${pkgs.lixPackageSets.latest.nix-direnv}/share/nix-direnv/direnvrc
    '')

    # Allow jujutsu usage
    (readonly (noescape "~/.config/jj"))
    (readonly (noescape "~/.config/git"))
    (readwrite (noescape "\"$PWD/.jj\""))
    (readwrite (noescape "\"$PWD/.git\""))

    # GitHub CLI auth for PR interactions (separate account from host)
    # Uses ~/.config/gh-pi so the sandbox gets its own gh identity.
    (readwrite (noescape "~/.config/gh-pi"))
    (set-env "GH_CONFIG_DIR" (noescape "~/.config/gh-pi"))

    # Allow Herdr integrations to report agent state and session identity.
    (try-fwd-env "HERDR_AGENT")
    (try-fwd-env "HERDR_BIN_PATH")
    (try-fwd-env "HERDR_ENV")
    (try-fwd-env "HERDR_PANE_ID")
    (try-fwd-env "HERDR_SOCKET_PATH")
    (add-runtime ''
      if [ -n "''${HERDR_SOCKET_PATH:-}" ]; then
        RUNTIME_ARGS+=(--bind "$HERDR_SOCKET_PATH" "$HERDR_SOCKET_PATH")
      fi
    '')

    # Spawn agent in a new jj workspace
    # Just don't spawn 2 agent in the same second. Thx
    (add-runtime ''
      date=$(date +"%Y%m%dT%H%M%S")
      export AGENT_SESSION_NAME="agent-$date"
      jj workspace add "./$AGENT_SESSION_NAME" --quiet -m "agent session $date"
    '')
    (rw-bind (noescape "\"$PWD/$AGENT_SESSION_NAME\"") (noescape "\"$PWD/agent\""))

    (wrap-entry (entry: ''
      cd ./agent
      ${lib.getExe pkgs.git} init
      ${lib.getExe pkgs.git} add .
      if [ -f .envrc ]; then
        direnv allow .
        direnv exec . ${entry}
      else
        ${entry}
      fi
      jj status
    ''))
    (add-cleanup ''
      if [ -n "$AGENT_SESSION_NAME" ]; then
        change_id=$(jj log --no-graph -r "$AGENT_SESSION_NAME@" -T 'change_id')
        is_empty=$(jj log --no-graph -r "$AGENT_SESSION_NAME@" -T 'if(empty, "true", "false")')
        jj workspace forget "$AGENT_SESSION_NAME" --quiet
        # Abandon the changeset if it is empty
        if [ "$is_empty" = "true" ]; then
          jj abandon "$change_id" --quiet
        fi
        rm -rf "$AGENT_SESSION_NAME"
      fi
    '')

    (add-pkg-deps (
      with pkgs;
      [
        # keep-sorted start
        bashInteractive
        curl
        diffutils
        direnv
        findutils
        gawkInteractive
        gh
        git
        gnugrep
        gnused
        gzip
        jq
        jujutsu
        lixPackageSets.latest.lix
        nixpkgs-review
        ps
        python3
        ripgrep
        tea
        unzip
        which
        # keep-sorted end
      ]
    ))
  ];
}
