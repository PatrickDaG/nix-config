{pkgs, ...}: {
  imports = [
    ./kitty.nix
    ./sway
    ./fuzzel.nix
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
      mpv
    ];
  };

  # notification are nice to have
  services.dunst.enable = true;
}
