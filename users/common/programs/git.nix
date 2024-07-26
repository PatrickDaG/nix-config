{ pkgs, ... }:
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
