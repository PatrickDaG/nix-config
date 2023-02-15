{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./starfish.nix
  ];
  programs.atuin = {
    enable = true;
    settings.auto_sync = false;
  };

  programs.fish = with lib; {
    enable = true;
    interactiveShellInit = lib.mkMerge [
      (lib.mkBefore ''
        set -g ATUIN_NOBIND true
        set -g fish_greeting
        set -g fish_autosuggestion_enabled 0
      '')
      (lib.mkAfter ''
                    bind \cr _atuin_search
              # prefix search for up and down arrow
              bind \e\[A history-prefix-search-backward
              bind \e\[B history-prefix-search-forward
              #Include atuin auto completions
              atuin gen-completions --shell fish | source
        set -g fzf_complete_opts --cycle --reverse --height=20%
      '')
    ];
    plugins = [
      {
        name = "fzf";
        src = pkgs.fetchFromGitHub {
          owner = "oddlama";
          repo = "fzf.fish";
          rev = "8c8b21ae52306cab5cece0095802ae15d0b8e3f4";
          sha256 = "07yhiqv2ag4k7fxrmqg8x66adr3gy5j1w2cs07pm0f1552jsz5jr";
        };
      }
    ];
  };
}
