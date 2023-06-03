{
  pkgs,
  config,
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
      directories = [
        "repos"
        "Downloads"

        "./Nextcloud"
        ".config/Nextcloud"
      ];
    };
  };
}
