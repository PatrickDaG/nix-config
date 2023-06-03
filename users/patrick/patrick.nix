{
  pkgs,
  config,
  extraLib,
  ...
}: {
  imports = [
    ./ssh.nix
  ];

  home = {
    packages = [
      pkgs.nextcloud-client
    ];
    persistence."/state/${config.home.homeDirectory}" = {
      allowOther = true;
      directories = extraLib.impermanence.makeSymlinks [
        "repos"
        "Downloads"

        "./Nextcloud"
        ".config/Nextcloud"
      ];
    };
  };
}
