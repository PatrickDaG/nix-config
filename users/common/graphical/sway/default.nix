{config, ...}: {
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "kitty";
      input = {
        "*" = {
          xkb_layout = "de";
          xkb_variant = "bone";
          repeat_delay = "350";
          repeat_rate = "60";
        };
      };
    };
  };
  # Cursor invisible
  home.sessionVariables.WLR_NO_HARDWARE_CURSORS = 1;
}
