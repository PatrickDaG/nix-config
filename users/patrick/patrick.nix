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
    persistence."/state/home/${config.home.username}" = {
      directories = [
        "repos"
        "Downloads"

        "./Nextcloud"
        ".config/Nextcloud"
      ];
    };
  };
}
