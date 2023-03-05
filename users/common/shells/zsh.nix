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
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    initExtra = lib.mkAfter (''
           function atuin-prefix-search() {
           	if out=$(${pkgs.sqlite}/bin/sqlite3 -readonly ~/.local/share/atuin/history.db \
           	  'SELECT command FROM history WHERE command LIKE cast('"x'$(str_to_hex "$_atuin_search_prefix")'"' as text) ||\
        "%" ORDER BY timestamp DESC LIMIT 1 OFFSET '"$_atuin_search_offset"); then
           	  [[ -z "$out" ]] && return 1
           	  BUFFER=$out
           	else
           	  return 1
           	fi

           }; zle -N atuin-prefix-search
      ''
      + (builtins.readFile ../../../data/zsh/zshrc));
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "aloxaf";
          repo = "fzf-tab";
          rev = "69024c27738138d6767ea7246841fdfc6ce0d0eb";
          sha256 = "07wwcplyb2mw10ia9y510iwfhaijnsdcb8yv2y3ladhnxjd6mpf8";
        };
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "fast-syntax-highlighting";
          rev = "7c390ee3bfa8069b8519582399e0a67444e6ea61";
          sha256 = "0gh4is2yzwiky79bs8b5zhjq9khksrmwlaf13hk3mhvpgs8n1fn0";
        };
      }
    ];
  };
}
