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
        };
      };
    };
  };
}
