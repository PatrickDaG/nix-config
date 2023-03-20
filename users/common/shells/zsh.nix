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
    # Atuin makes completion and this really _really_ slows zsh startup time down
    enableCompletion = false;
    initExtra = lib.mkAfter (''
              function atuin-prefix-search() {
              	if out=$(${pkgs.sqlite}/bin/sqlite3 -readonly ~/.local/share/atuin/history.db \
              	  'SELECT command FROM history WHERE command LIKE cast('"x'$(str_to_hex "$_atuin_search_prefix")'"' as text) ||
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
          rev = "5a81e13792a1eed4a03d2083771ee6e5b616b9ab";
          sha256 = "0lfl4r44ci0wflfzlzzxncrb3frnwzghll8p365ypfl0n04bkxvl";
        };
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "fast-syntax-highlighting";
          rev = "5521b083f8979ad40be2137d7a46bfa51c8d666a";
          sha256 = "0ki5dl3gvmcl1kr9smx0949303dxzwadz7r4abj7ivj3284xxk44";
        };
      }
    ];
  };
}
