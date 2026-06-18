{
  pkgs,
  lib,
  globals,
  ...
}:
{
  imports = [ ./starship.nix ];
  # save history in xdg data home
  hm-all =
    { config, ... }:
    {
      # Completely disable caching
      home.sessionVariables.COMMA_CACHING = "0";

      # has to be enabled to support zsh reverse search
      programs.fzf = {
        enable = true;
        # copy terminal background
        colors.bg = lib.mkForce "#000000";
      };

      programs.zoxide.enable = true;

      programs.nix-index.enable = true;
      programs.nix-index.enableZshIntegration = false;
      programs.nix-index-database.comma.enable = true;

      programs.zsh = {
        enable = true;
        dotDir = "${config.xdg.configHome}/zsh";
        history = {
          extended = true;
          path = "${config.xdg.dataHome}/zsh/zsh_history";
          save = 1000000;
          share = false;
        };
        # This needs to be loaded befor zsh-fast-syntax-highlighting
        # is sourced as that overwrites all widgets to redraw with highlighting
        initContent = lib.mkMerge [
          (lib.mkBefore ''
            if autoload history-search-end; then
            	zle -N history-beginning-search-backward-end history-search-end
            	zle -N history-beginning-search-forward-end  history-search-end
            fi
          '')
          (builtins.readFile ./zshrc)
          # TODO: rename hex -> pty-proxy once on atuin 18.16
          "eval \"$(atuin hex init zsh)\""
        ];
        plugins = [
          {
            name = "fzf-tab";
            src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
          }
          {
            name = "fast-syntax-highlighting";
            src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting";
          }
        ];
      };
      programs.atuin = {
        daemon.enable = true;
        enable = true;
        enableZshIntegration = true;
        flags = [
          "--disable-up-arrow"
        ];
        settings = {
          auto_sync = true;
          update_check = false;
          sync_address = "https://${globals.services.atuin.domain}";
          sync_frequency = "15m";
          workspaces = true;
          ui.columns = [
            "duration"
            "time"
            {
              type = "host";
              width = 10;
            }
            {
              type = "command";
              # This does not expand all available space only enough so the text fills
              # Meaning the directory is not on the right hand side
              expand = true;
            }
            {
              type = "directory";
              width = 30;
            }
          ];
          search = {
            filters = [
              "directory"
              "global"
              "session"
              "workspace"
            ];
          };
          ai.enabled = false;
          show_numeric_shortcuts = true;
          search_mode_shell_up_key_binding = "prefix";
          history_filter = [
            "^ "
            "^rm"
            "^[a-z,A-Z] "
          ];
        };
      };
      home.persistence."/state".directories = [
        ".local/share/zsh"
        ".local/share/zoxide"
        ".local/share/atuin"
      ];
    };
}
