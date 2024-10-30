{ pkgs, lib, ... }:
{
  hm.stylix.targets.kitty.enable = true;
  hm.programs.kitty = {
    enable = true;
    package = pkgs.kitty.overrideAttrs (_finalAttrs: _prevAttrs: { doCheck = false; });
    settings = {
      # Use xterm-256color because copying terminfo-kitty is painful.
      term = "xterm-256color";

      # make kitty go brrrr
      repaint_delay = 8;
      input_delay = 0;
      sync_to_monitor = "no";

      # Do not wait for inherited child processes.
      close_on_child_death = "yes";

      # Disable ligatures.
      disable_ligatures = "cursor";

      # Modified onehalfdark color scheme
      cursor = "#cccccc";
      shell_integration = "disabled";

      selection_foreground = "#282c34";
      selection_background = "#979eab";

      # Disable cursor blinking
      cursor_blink_interval = "0";

      # Big fat scrollback buffer
      scrollback_lines = "100000";
      # Set scrollback buffer for pager in MB
      scrollback_pager_history_size = "256";

      # Don't copy on select
      copy_on_select = "no";

      # Set program to open urls with
      open_url_with = "xdg-open";

      # Fuck the bell
      enable_audio_bell = "no";
    };
    keybindings = {
      # Keyboard mappings
      "shift+page_up" = "scroll_page_up";
      "shift+page_down" = "scroll_page_down";
      "ctrl+shift+." = "change_font_size all -2.0";
      "ctrl+shift+," = "change_font_size all +2.0";
    };
    extraConfig = lib.mkAfter ''
      # Use nvim as scrollback pager
      scrollback_pager nvim -u NONE -c "set nonumber nolist showtabline=0 foldcolumn=0 laststatus=0" -c "autocmd TermOpen * normal G" -c "silent write! /tmp/kitty_scrollback_buffer | te head -c-1 /tmp/kitty_scrollback_buffer; rm /tmp/kitty_scrollback_buffer; cat"
      background #000000
    '';
  };
}
