{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.atuin = {
    enable = true;
    settings.auto_sync = false;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$username"
        "$hostname"
        " $directory"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_status"
        "$nix_shell"
        "$character"
      ];

      right_format = lib.concatStrings [
        "$cmd_duration"
        "$status"
        "$jobs"
        "$time"
      ];

      username = {
        style_user = "yellow";
        style_root = "bold red";
        show_always = true;
        format = "[$user]($style)";
      };

      hostname = {
        style = "red";
        format = "@[$hostname]($style)";
      };

      directory = {
        format = "[$path]($style)[$read_only]($read_only_style) ";
        fish_style_pwd_dir_length = 1;
        truncate_to_repo = false;
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style)";
      };

      git_status = {
        conflicted = "$count";
        ahead = "⇡$count";
        behind = "⇣$count";
        diverged = "⇡$ahead_count⇣$behind_count";
        untracked = "?$count";
        stashed = "\\$$count";
        modified = "!$count";
        staged = "+$count";
        renamed = "→$count";
        deleted = "-$count";
        format = lib.concatStrings [
          "[( $conflicted)](red)"
          "[( $stashed)](magenta)"
          "[( $staged)](green)"
          "[( $deleted)](red)"
          "[( $renamed)](blue)"
          "[( $modified)](yellow)"
          "[( $untracked)](blue)"
          "[( $ahead_behind)](green)"
        ];
      };

      nix_shell = {
        heuristic = true;
      };

      cmd_duration = {
        format = "[ $duration]($style) ";
        style = "yellow";
      };

      status = {
        disabled = false;
        pipestatus = true;
        style = "red";
        pipestatus_format = "$pipestatus -> [$int( $signal_name)]($style)";
        pipestatus_separator = "[ | ]($style)";
        pipestatus_segment_format = "[$status]($style)";
        format = "[$status( $signal_name)]($style) ";
      };

      time = {
        disabled = false;
        format = "[ $time]($style)";
        style = "yellow";
      };
    };
  };

  programs.fish = with lib; {
    enable = true;
    interactiveShellInit = lib.mkMerge [
      (lib.mkBefore ''
                set -g ATUIN_NOBIND true
                set -g fish_greeting
        set -g fish_autosuggestion_enabled 0
        set -U FZF_COMPLETE 2
      '')
      (lib.mkAfter ''
        bind \cr _atuin_search
      '')
    ];
    plugins = [
      {
        name = "fzf";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "fzf";
          rev = "479fa67d7439b23095e01b64987ae79a91a4e283";
          sha256 = "0k6l21j192hrhy95092dm8029p52aakvzis7jiw48wnbckyidi6v";
        };
      }
    ];
  };
}
