{
  pkgs,
  lib,
  globals,
  ...
}:
let
  sshSigningKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZixkix0KfKuq7Q19whS5FQQg51/AJGB5BiNF/7h/LM cardno:15 489 049"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxD4GOrwrBTG4/qQhm5hoSB2CP7W9g1LPWP11oLGOjQ cardno:23 010 997"
  ];
  sshSigningKeyFiles = lib.imap1 (
    index: key: pkgs.writeText "patrick-yubikey-${toString index}.pub" "${key}\n"
  ) sshSigningKeys;
  allowedSigners = pkgs.writeText "patrick-allowed-signers" (
    lib.concatMapStrings (key: "patrick@${globals.domains.mail_public} ${key}\n") sshSigningKeys
  );
  sshKeygen = lib.getExe' pkgs.openssh "ssh-keygen";
  selectSshSigningKey = lib.getExe (
    pkgs.writeShellApplication {
      name = "ssh-keygen-select-yubikey";
      runtimeInputs = [ pkgs.openssh ];
      text = ''
        args=("$@")
        signing=false

        for ((i = 0; i + 1 < ''${#args[@]}; i++)); do
          if [[ ''${args[$i]} == "-Y" && ''${args[$((i + 1))]} == "sign" ]]; then
            signing=true
            break
          fi
        done

        if ! $signing; then
          exec ${sshKeygen} "''${args[@]}"
        fi

        if ! agent_keys=$(ssh-add -L); then
          echo "Unable to list keys from SSH agent; is SSH_AUTH_SOCK available?" >&2
          exit 1
        fi

        selected_key=""
        matches=0
        known_key_files=(${lib.escapeShellArgs (map toString sshSigningKeyFiles)})

        for known_key_file in "''${known_key_files[@]}"; do
          read -r known_type known_blob _ < "$known_key_file"
          while IFS= read -r agent_key; do
            read -r agent_type agent_blob _ <<< "$agent_key"
            if [[ $known_type == "$agent_type" && $known_blob == "$agent_blob" ]]; then
              selected_key=$known_key_file
              matches=$((matches + 1))
              break
            fi
          done <<< "$agent_keys"
        done

        if ((matches == 0)); then
          echo "SSH agent does not contain a configured YubiKey signing key" >&2
          exit 1
        elif ((matches > 1)); then
          echo "SSH agent contains multiple configured YubiKey signing keys; expose only the active key" >&2
          exit 1
        fi

        found_key_argument=false
        for ((i = 0; i + 1 < ''${#args[@]}; i++)); do
          if [[ ''${args[$i]} == "-f" ]]; then
            args[i + 1]=$selected_key
            found_key_argument=true
            break
          fi
        done

        if ! $found_key_argument; then
          echo "ssh-keygen signing invocation has no -f key argument" >&2
          exit 1
        fi

        exec ${sshKeygen} "''${args[@]}"
      '';
    }
  );
  gf = lib.getExe (
    pkgs.writeShellApplication {
      name = "git-fixup-fzf";
      runtimeInputs = [
        pkgs.fzf
        pkgs.gnugrep
      ];
      text = ''
        if ! commit=$(set +o pipefail; git log --graph --color=always --format="%C(auto)%h%d %s %C(reset)%C(bold)%cr" "$@" \
          | fzf --ansi --multi --no-sort --reverse --print-query --expect=ctrl-d --toggle-sort=\`); then
          echo aborted
          exit 0
        fi

        sha=$(grep -o '^[^a-z0-9]*[a-z0-9]\{7\}[a-z0-9]*' <<< "$commit" | grep -o '[a-z0-9]\{7\}[a-z0-9]*')
        if [[ -z "$sha" ]]; then
          echo "Found no checksum for selected commit. Aborting."
          exit 1
        fi

        git fixup "$sha" "$@"
      '';
    }
  );
in
{
  home.persistence."/state".directories = [
    ".config/jj/repos"
  ];
  home.packages = with pkgs; [
    gfold
  ];
  xdg.configFile."gfold/config.toml".text = ''
    paths = ['/home/patrick/repos']
    display_mode = 'Classic'
  '';
  programs.jujutsu = {
    enable = true;
    settings = {
      signing = {
        behavior = "drop";
        backend = "ssh";
        key = builtins.head sshSigningKeyFiles;
        backends.ssh = {
          program = selectSshSigningKey;
          allowed-signers = allowedSigners;
        };
      };
      git.sign-on-push = true;
      revset-aliases = {
        "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
      };
      templates = {
        draft_commit_description = ''
          concat(
            coalesce(description, default_commit_description, "\n"),
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.stat(72)),
            ),
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
        # commit_trailers = ''
        #   format_signed_off_by_trailer(self)
        #   ++ if(!trailers.contains_key("Change-Id"), format_gerrit_change_id_trailer(self))
        # '';
        git_push_bookmark = "'patrick/push-' ++ change_id.short()";
      };
      aliases = {
        tug = [
          "bookmark"
          "move"
          "--from"
          "closest_bookmark(@-)"
          "--to"
          "@-"
        ];
        l = [
          "log"
          "--limit"
          "30"
          "--revisions"
          "::"
        ];
        # I think this is kinda not working
        rebase-all = [
          "rebase"
          "--source"
          "roots(trunk()..mine())"
          "--destination"
          "trunk()"
        ];
      };
      remotes = {
        origin.auto-track-bookmarks = "patrick*";
        upstream.auto-track-bookmarks = "ma*";
      };
      ui = {
        default-command = "l";
        # Why no paginate if longer than a page??
        paginate = "never";
        diff-editor = ":builtin";
      };
      user = {
        email = "patrick@${globals.domains.mail_public}";
        name = "Patrick";
      };
    };
  };

  programs.gitui.enable = true;
  programs.difftastic = {
    enable = true;
    git.enable = true;
  };
  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [ ".direnv" ];
    signing = {
      format = "ssh";
      key = builtins.head sshSigningKeyFiles;
      signByDefault = true;
    };
    settings = {
      gpg.ssh = {
        program = selectSshSigningKey;
        allowedSignersFile = allowedSigners;
      };
      core.pager = "${pkgs.delta}/bin/delta";
      user = {
        name = "Patrick";
        email = globals.accounts.email."1".address;
        #signingkey = globals.accounts.email."1".address;
      };
      sendemail.identity = globals.accounts.email."1".address;
      delta = {
        hyperlinks = true;
        keep-plus-minus-markers = true;
        line-numbers = true;
        navigate = true;
        side-by-side = true;
        syntax-theme = "TwoDark";
        tabs = 4;
      };
      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "version:refname";
      mergetool.prompt = true;
      merge.conflictstyle = "diff3";
      init.defaultBranch = "main";
      push.followTags = true;
      pull.ff = "only";
      pull.rebase = true;
      push.autoSetupRemote = true;
      fetch.prune = true;
      fetch.pruneTags = true;
      fetch.all = true;
      commit.verbose = true;
      rerere.enabled = true;
      rerere.autoupdate = true;
      rebase.autoSquash = true;
      rebase.autoStash = true;
      rebase.updateRefs = true;
      alias = {
        cs = "commit -v -S";
        s = "status";
        a = "add";
        p = "push";
        rebase = "rebase --gpg-sign";
        fixup = ''!f() { TARGET=$(git rev-parse "$1"); git commit --fixup=$TARGET ''${@:2} && EDITOR=true git rebase -i --gpg-sign --autostash --autosquash $TARGET^; }; f'';
        f = "!${gf}";
        crm = ''!git commit -v -S --edit --file "$(git rev-parse --git-dir)"/COMMIT_EDITMSG'';
      };
    };
  };
}
