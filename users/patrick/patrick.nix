{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      nextcloud-client
      discord
      lutris
      wine-wayland
      winetricks
    ];
  };
}
