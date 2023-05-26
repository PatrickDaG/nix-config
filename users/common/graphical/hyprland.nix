{
  pkgs,
  lib,
  ...
}: let
  MOD = "SUPER";
  TAGS = map toString (lib.lists.range 41 49);
in {
  imports = [./waybar.nix];
  # This does not work currently no idea why
  programs.waybar.settings.main."wlr/workspaces".persistent_workspaces = builtins.listToAttrs (map (x: {
      name = x;
      value = [];
    })
    ["42" "43" "44"]);

  home.packages = with pkgs; [
    qt6.qtwayland
    wl-clipboard
  ];

  home.sessionVariables.NIXOS_OZONE_WL = 1;

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.hidpi = true;
    nvidiaPatches = true;
    extraConfig = import ./hyprland.conf.nix MOD TAGS pkgs;
  };
}
