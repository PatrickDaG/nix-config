{
  lib,
  stateVersion,
  config,
  #deadnix: skip
  pkgs, # not unused needed for the usage of attrs later to contains pkgs
  ...
} @ attrs: let
  hostName = "nc.${config.secrets.secrets.global.domains.mail}";
in {
  imports = [./containers.nix ./ddclient.nix ./acme.nix];
  services.nginx = {
    enable = true;
    recommendedSetup = true;
    upstreams.nextcloud = {
      servers."192.168.178.33:80" = {};

      extraConfig = ''
        zone nextcloud 64k ;
        keepalive 5 ;
      '';
    };
    virtualHosts.${hostName} = {
      forceSSL = true;
      useACMEHost = "mail";
      locations."/".proxyPass = "http://nextcloud";
      extraConfig = ''
        client_max_body_size 4G ;
      '';
    };
  };
  containers.nextcloud = lib.containers.mkConfig "nextcloud" attrs {
    zfs = {
      enable = true;
      pool = "panzer";
    };
    config = {
      config,
      pkgs,
      ...
    }: {
      #TODO enable recommended nginx setup
      systemd.network.networks = {
        "lan01" = {
          address = ["192.168.178.33/24"];
          gateway = ["192.168.178.1"];
          matchConfig.Name = "lan01*";
          dns = ["192.168.178.2"];
          networkConfig = {
            IPv6PrivacyExtensions = "yes";
            MulticastDNS = true;
          };
        };
      };
      environment.persistence."/persist".directories = [
        {
          directory = config.services.nextcloud.home;
          user = "nextcloud";
          group = "nextcloud";
          mode = "750";
        }
      ];
      services.nextcloud = {
        inherit hostName;
        enable = true;
        package = pkgs.nextcloud28;
        configureRedis = true;
        config.adminpassFile = "${pkgs.writeText "adminpass" "test123"}"; # DON'T DO THIS IN PRODUCTION - the password file will be world-readable in the Nix Store!
        config.adminuser = "admin";
        extraApps = with config.services.nextcloud.package.packages.apps; {
          inherit contacts calendar tasks notes maps;
        };
        # TODO increase outer nginx upload size as well
        maxUploadSize = "2G";
        extraAppsEnable = true;
        database.createLocally = true;
        phpOptions."opcache.interned_strings_buffer" = "32";
        extraOptions = {
          trusted_proxies = ["192.168.178.32"];
          overwriteprotocol = "https";
          enabledPreviewProviders = [
            "OC\\Preview\\BMP"
            "OC\\Preview\\GIF"
            "OC\\Preview\\JPEG"
            "OC\\Preview\\Krita"
            "OC\\Preview\\MarkDown"
            "OC\\Preview\\MP3"
            "OC\\Preview\\OpenDocument"
            "OC\\Preview\\PNG"
            "OC\\Preview\\TXT"
            "OC\\Preview\\XBitmap"
            "OC\\Preview\\HEIC"
          ];
        };
        config = {
          defaultPhoneRegion = "DE";
          dbtype = "pgsql";
        };
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
#maddy
#kanidm
#remote backups
#immich

