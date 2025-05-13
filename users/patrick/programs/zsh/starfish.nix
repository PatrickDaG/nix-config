{ lib, ... }:
{
  hm-all.programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$username"
        "$hostname"
        " $directory "
        #"($git_branch )"
        #"($git_commit )"
        #"$git_state"
        #"$git_status"
        ''(''${custom.jj} )''
        ''(''${custom.jjstate} )''
        "$character"
      ];

      right_format = lib.concatStrings [
        "($nix_shell )"
        "($cmd_duration )"
        "($status )"
        "($jobs)"
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
        format = "[$path]($style)[$read_only]($read_only_style)";
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
      custom.jj = {
        command = ''
            jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
            separate(" ",
              change_id.shortest(4),
              bookmarks,
              "|",
              concat(
                if(conflict, "💥"),
                if(divergent, "🚧"),
                if(hidden, "👻"),
                if(immutable, "🔒"),
              ),
              raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)"),
              raw_escape_sequence("\x1b[1;32m") ++ coalesce(
                truncate_end(29, description.first_line(), "…"),
                "(no desc)",
              ) ++ raw_escape_sequence("\x1b[0m"),
            )
          '
        '';
        symbol = "jj";
        detect_folders = [ ".jj" ];
        format = "[$output]($style)";
      };

      custom.jjstate = {
        detect_folders = [ ".jj" ];
        command = ''
          jj log -r@ -n1 --no-graph -T "" --stat | tail -n1 | sd "(\d+) files? changed, (\d+) insertions?\(\+\), (\d+) deletions?\(-\)" ' ''${1}m ''${2}+ ''${3}-' | sd " 0." ""
        '';
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
