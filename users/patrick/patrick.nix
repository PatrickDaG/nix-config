{pkgs, ...}: {
  images.enable = true;
  home = {
    packages = with pkgs; [
      nextcloud-client
      discord
      netflix
    ];
  };
}
