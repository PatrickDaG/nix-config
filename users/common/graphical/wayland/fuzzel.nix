{ lib, ... }:
{
  stylix.targets.fuzzel.enable = true;
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        launch-prefix = "uwsm app --";
      };
      colors.background = lib.mkForce "000000ff";
    };
  };
}
