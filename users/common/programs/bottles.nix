{pkgs, ...}: {
  home.packages = with pkgs; [
    bottles
    winetricks
    wineWowPackages.fonts
    wineWowPackages.stagingFull
  ];
  # To enable dark mode use the command:
  #  dconf write /com/usebottles/bottles/dark-theme true
}
