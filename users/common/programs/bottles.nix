{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    bottles
    winetricks
    wineWowPackages.fonts
    wineWowPackages.stagingFull
  ];
}
