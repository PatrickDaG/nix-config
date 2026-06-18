{ lib, pkgs, ... }:
{
  hm-all.programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$username"
        "$hostname"
        " $directory "
        "(\${custom.jj} )"
        "$fill"
        "($nix_shell )"
        "($cmd_duration )"
        "($status )"
        "($jobs)"
        "$time"
        "$line_break"
        "$character"
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
        format = "[$path]($style)[$read_only]($read_only_style)";
        fish_style_pwd_dir_length = 1;
        truncate_to_repo = false;
      };
      fill = {
        symbol = " ";
      };

      custom.jj = {
        command = "prompt";
        format = "$output";
        ignore_timeout = true;
        shell = [
          "${pkgs.starship-jj}/bin/starship-jj"
          "--ignore-working-copy"
          "starship"
        ];
        use_stdin = false;
        "when" = true;
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
          "[($conflicted )](red)"
          "[($stashed )](magenta)"
          "[($staged )](green)"
          "[($deleted )](red)"
          "[($renamed )](blue)"
          "[($modified )](yellow)"
          "[($untracked )](blue)"
          "[($ahead_behind )](green)"
        ];
      };

      nix_shell = {
        format = "[󰜗 $name]($style)";
      };

      cmd_duration = {
        format = "[ $duration]($style)";
        style = "yellow";
      };

      status = {
        disabled = false;
        pipestatus = true;
        style = "red";
        pipestatus_format = "$pipestatus -> [$int( $signal_name)]($style)";
        pipestatus_separator = "[ | ]($style)";
        pipestatus_segment_format = "[$status]($style)";
        format = "[$status( $signal_name)]($style)";
      };

      time = {
        disabled = false;
        format = "[ $time]($style)";
        style = "yellow";
      };
    };
  };
}
