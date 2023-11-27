{lib, ...}: {
  containers.nextcloud = {
    autoStart = true;
    macvlans = [
      "lan01"
    ];
    config = {
      config,
      pkgs,
      ...
    }: {
      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud27;
        hostName = "localhost";
        config.adminpassFile = "${pkgs.writeText "adminpass" "test123"}"; # DON'T DO THIS IN PRODUCTION - the password file will be world-readable in the Nix Store!
      };

      system.stateVersion = "23.05";

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [80];
        };
        # Use systemd-resolved inside the container
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;
      bindMounts.data = {
        mountPoint = "/persist";
        hostPath = "/persist/containers/nextcloud";
      };
    };
  };
}
