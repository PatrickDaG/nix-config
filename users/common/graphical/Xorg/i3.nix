{config, ...}: {
  # import shared sway config
  imports = [../sway3.nix];
  stylix.targets.i3.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
    config = {
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