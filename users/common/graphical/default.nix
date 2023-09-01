{pkgs, ...}: {
  imports = [
    ./kitty.nix
    ./sway
    ./rofi.nix
    ./firefox.nix
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
