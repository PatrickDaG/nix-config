{pkgs, ...}: {
  home = {
    packages = [
      pkgs.nextcloud-client
    ];
  };
}
