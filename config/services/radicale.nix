{
  lib,
  stateVersion,
  config,
  pkgs, # not unused needed for the usage of attrs later to contains pkgs
  ...
}@attrs:
let
  hostName = "radicale.${config.secrets.secrets.global.domains.mail}";
in
{
  imports = [
    ./containers.nix
    ./ddclient.nix
    ./acme.nix
  ];
  services.nginx = {
    enable = true;
    upstreams.radicale = {
      servers."192.168.178.34:8000" = { };

      extraConfig = ''
        zone radicale 64k ;
        keepalive 5 ;
      '';
    };
    virtualHosts.${hostName} = {
      forceSSL = true;
      useACMEHost = "mail";
      locations."/".proxyPass = "http://radicale";
    };
  };
  containers.nextcloud = lib.containers.mkConfig "nextcloud" attrs {
    zfs = {
      enable = true;
      pool = "panzer";
    };
    config = _: {
      systemd.network.networks = {
        "lan01" = {
          address = [ "192.168.178.34/24" ];
          gateway = [ "192.168.178.1" ];
          matchConfig.Name = "lan01*";
          dns = [ "192.168.178.2" ];
          networkConfig = {
            IPv6PrivacyExtensions = "yes";
          };
        };
      };
      environment.persistence."/persist".directories = [
        {
          directory = "/var/lib/radicale";
          user = "radicale";
          group = "radicale";
          mode = "750";
        }
      ];
      services.radicale = {
        enable = true;
        setting = {
          server = {
            hosts = [
              "0.0.0.0:8000"
              "[::]:8000"
            ];
            auth = {
              type = "htpasswd";
              htpasswd_filename = "/etc/radicale/users";
              htpasswd_encryption = "bcrypt";
            };
            storage = {
              filesystem_folder = "/var/lib/radicale";
            };
          };
        };
        rights = {
          root = {
            user = ".+";
            collection = "";
            permissions = "R";
          };
          principal = {
            user = ".+";
            collection = "{user}";
            permissions = "RW";
          };
          calendars = {
            user = ".+";
            collection = "{user}/[^/]+";
            permissions = "rw";
          };
        };
      };

      system.stateVersion = stateVersion;

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 8000 ];
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
