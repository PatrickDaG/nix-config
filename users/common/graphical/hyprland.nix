{
  pkgs,
  lib,
  ...
}: let
  MOD = "SUPER";
  TAGS = map toString (lib.lists.range 42 50);
in {
  wayland.windowManager.hyprland = {
    enable = true;
    nvidiaPatches = true;
    extraConfig = import ../../../data/hyprland/config.nix MOD TAGS pkgs;
  };
}
