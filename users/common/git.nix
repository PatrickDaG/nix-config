{
  programs.git = {
    enable = true;
    difftastic.enable = true;
    aliases = {
      cs = "commit -v -S";
      s = "status";
      a = "add";
      p = "push";
    };
    extraConfig = {
      mergetool.prompt = true;
      merge.conflictstyle = "diff3";
      init.defaultBranch = "main";
      pull.ff = "only";
      pull.rebase = true;
    };
    signing = {
      key = null;
      signByDefault = true;
    };
  };
}
