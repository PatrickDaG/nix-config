{ pkgs, lib, ... }:
let
  gf = lib.getExe (
    pkgs.writeShellApplication {
      name = "git-fixup-fzf";
      runtimeInputs = [
        pkgs.fzf
        pkgs.gnugrep
      ];
      text = ''
        if ! commit=$(git log --graph --color=always --format="%C(auto)%h%d %s %C(reset)%C(bold)%cr" "$@" \
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
      mergetool.prompt = true;
      merge.conflictstyle = "diff3";
      init.defaultBranch = "main";
      pull.ff = "only";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
    signing = {
      key = null;
      signByDefault = true;
    };
  };
}
