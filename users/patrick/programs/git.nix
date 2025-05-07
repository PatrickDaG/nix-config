{
  pkgs,
  lib,
  globals,
  ...
}:
let
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
  hm = {
    programs.jujutsu = {
      enable = true;
      settings = {
        revset-aliases."immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
        signing = {
          # Only sign on push
          behaviour = "drop";
          backend = "gpg";
        };
        git.sign-on-push = true;
        ui = {
          default-command = "log";
          paginate = "never";
        };
        user = {
          email = "patrick@${globals.domains.mail_public}";
          name = "Patrick";
        };
      };
    };

    programs.gitui.enable = true;
    programs.git = {
      enable = true;
      difftastic.enable = true;
      lfs.enable = true;
      aliases = {
        cs = "commit -v -S";
        s = "status";
        a = "add";
        p = "push";
        rebase = "rebase --gpg-sign";
        fixup = ''!f() { TARGET=$(git rev-parse "$1"); git commit --fixup=$TARGET ''${@:2} && EDITOR=true git rebase -i --gpg-sign --autostash --autosquash $TARGET^; }; f'';
        f = "!${gf}";
        crm = ''!git commit -v -S --edit --file "$(git rev-parse --git-dir)"/COMMIT_EDITMSG'';
      };
      ignores = [ ".direnv" ];
      extraConfig = {
        core.pager = "${pkgs.delta}/bin/delta";
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
      };
      signing = {
        key = null;
        signByDefault = true;
      };
    };
  };
}
