{
  config,
  lib,
  ...
}: {
  xsession.windowManager.i3 = {
    enable = true;
    config =
      lib.attrsets.recursiveUpdate
      (import ../sway3.nix)
      {
        menu = "rofi -show drun";
        keybindings = let
          cfg = config.xsession.windowManager.i3.config;
        in {
          "Menu" = "exec ${cfg.menu}";
          "${cfg.modifier}+c" = "exec ${cfg.menu}";
        };
      };
  };
}
