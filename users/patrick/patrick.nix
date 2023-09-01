{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      nextcloud-client
      heroic
      discord
    ];
  };
}
