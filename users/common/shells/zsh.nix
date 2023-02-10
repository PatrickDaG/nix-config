{
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    initExtra = builtins.readFile ../../data/zsh/zshrc;
    plugins = [
      {
        name = "powerlevel10k";
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        src = pkgs.zsh-powerlevel10k;
      }
      {
        name = "fzf-tab";
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
        src = pkgs.zsh-fzf-tab;
      }
      {
        name = "fast-syntax-highlighting";
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
        src = pkgs.zsh-fast-syntax-highlighting;
      }
      {
        name = "zsh-histdb";
        file = "sqlite-history.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "larkery";
          repo = "zsh-histdb";
          rev = "30797f0";
          sha256 = "PQIFF8kz+baqmZWiSr+wc4EleZ/KD8Y+lxW2NT35/bg=";
        };
      }
      {
        name = "sd";
        file = "sd.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "ianthehenry";
          repo = "sd";
          rev = "v1.1.0";
          sha256 = "X5RWCJQUqDnG2umcCk5KS6HQinTJVapBHp6szEmbc4U=";
        };
      }
    ];
  };
}
