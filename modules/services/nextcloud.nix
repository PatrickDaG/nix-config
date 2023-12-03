{
  lib,
  stateVersion,
  ...
}: {
  imports = [./containers.nix];
  containers.nextcloud = lib.containers.mkConfig "nextcloud" {
    autoStart = true;
    zfs = {
      enable = true;
      pool = "panzer";
    };
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

      system.stateVersion = stateVersion;

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [80];
        };
        # Use systemd-resolved inside the container
        useHostResolvConf = lib.mkForce false;
      };

      services.resolved.enable = true;
    };
  };
}
#wireguard
#samba/printer finding
#vaultwarden
#nextcloud
#acme
#nginx
#maddy
#kanidm
#xdg portals
#zfs snapshots
#remote backups
#immich

