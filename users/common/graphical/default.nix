{pkgs, ...}: {
  imports = [
    ./kitty.nix
    ./Xorg
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
  gtk.gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = 1;
  };
}
