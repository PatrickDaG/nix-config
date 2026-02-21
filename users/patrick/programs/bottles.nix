{ pkgs, ... }:
{
  hm.home.packages = with pkgs; [
    bottles
    winetricks
    wineWow64Packages.fonts
    wineWow64Packages.stagingFull
  ];
  # To enable dark mode use the command:
  #  dconf write /com/usebottles/bottles/dark-theme true
  hm.home.persistence."/state".directories = [
    # bottles state games
    ".local/share/bottles"

  ];
}
