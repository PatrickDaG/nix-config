{ pkgs, lib, ... }:
{
  hm.stylix.targets.kitty.enable = true;
  hm.home.sessionVariables = {
    TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo";
    TERMINAL = "kitty";
  };
  hm.programs.kitty = {
    enable = true;
    settings = {
      # Add nerd font symbol map. Not sure why it is suddenly needed since 0.32.0 (https://github.com/kovidgoyal/kitty/issues/7081)
      symbol_map = "U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A2,U+E0A3,U+E0B0-U+E0B3,U+E0B4-U+E0C8,U+E0CA,U+E0CC-U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E6B1,U+E700-U+E7C5,U+EA60-U+EBEB,U+F000-U+F2E0,U+F300-U+F372,U+F400-U+F532,U+F500-U+FD46,U+F0001-U+F1AF0 Symbols Nerd Font Mono";

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
      url_prefixes = "file ftp ftps gemini git gopher http https irc ircs kitty mailto news sftp ssh steam";

      # Fuck the bell
      enable_audio_bell = "no";
    };
    keybindings = {
      # Keyboard mappings
      "shift+page_up" = "scroll_page_up";
      "shift+page_down" = "scroll_page_down";
      "ctrl+shift+." = "change_font_size all -2.0";
      "ctrl+shift+," = "change_font_size all +2.0";
      "ctrl+shift+w" = "no_op";
    };
    extraConfig = lib.mkAfter ''
      # Use nvim as scrollback pager
      scrollback_pager nvim -u NONE -c "set nonumber nolist showtabline=0 foldcolumn=0 laststatus=0" -c "autocmd TermOpen * normal G" -c "silent write! /tmp/kitty_scrollback_buffer | te head -c-1 /tmp/kitty_scrollback_buffer; rm /tmp/kitty_scrollback_buffer; cat"
      background #000000
    '';
  };
}
