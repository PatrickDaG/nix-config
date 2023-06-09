{pkgs, ...}: {
  imports = [
    ./graphical/kitty.nix
    ./graphical/hyprland
    ./graphical/rofi.nix
    ./graphical/firefox.nix
  ];
  home = {
    packages = with pkgs; [
      thunderbird
      signal-desktop
      chromium
      xdragon
      xournalpp
      zathura
      pinentry
      feh
      galaxy-buds-client
      netflix
    ];
  };

  # notification are nice to have
  services.dunst.enable = true;
}
