{
  config,
  stateVersion,
  inputs,
  lib,
  minimal,
  nodes,
  ...
}: let
  adguardhomedomain = "adguardhome.${config.secrets.secrets.global.domains.web}";
  nextclouddomain = "nc.${config.secrets.secrets.global.domains.web}";
  giteadomain = "git.${config.secrets.secrets.global.domains.web}";
  vaultwardendomain = "pw.${config.secrets.secrets.global.domains.web}";
  ipOf = hostName: lib.net.cidr.host config.secrets.secrets.global.net.ips."${config.guests.${hostName}.nodeName}" config.secrets.secrets.global.net.privateSubnet;
in {
  services.nginx = {
    enable = true;
    recommendedSetup = true;
    upstreams.vaultwarden = {
      servers."${ipOf "vaultwarden"}:3000" = {};

      extraConfig = ''
        zone vaultwarden 64k ;
        keepalive 5 ;
      '';
    };
    virtualHosts.${vaultwardendomain} = {
      forceSSL = true;
      useACMEHost = "web";
      locations."/" = {
        proxyPass = "http://vaultwarden";
        proxyWebsockets = true;
      };
      extraConfig = ''
        client_max_body_size 1G ;
      '';
    };
    upstreams.gitea = {
      servers."${ipOf "gitea"}:3000" = {};

      extraConfig = ''
        zone gitea 64k ;
        keepalive 5 ;
      '';
    };
    virtualHosts.${giteadomain} = {
      forceSSL = true;
      useACMEHost = "web";
      locations."/" = {
        proxyPass = "http://gitea";
        proxyWebsockets = true;
      };
      extraConfig = ''
        client_max_body_size 1G ;
      '';
    };
    upstreams.adguardhome = {
      servers."${ipOf "adguardhome"}:3000" = {};

      extraConfig = ''
        zone adguardhome 64k ;
        keepalive 5 ;
      '';
    };
    virtualHosts.${adguardhomedomain} = {
      forceSSL = true;
      useACMEHost = "web";
      locations."/" = {
        proxyPass = "http://adguardhome";
        proxyWebsockets = true;
      };
      extraConfig = ''
        allow 192.168.178.0/24;
        deny all;
      '';
    };
    upstreams.nextcloud = {
      servers."${ipOf "nextcloud"}:80" = {};

      extraConfig = ''
        zone nextcloud 64k ;
        keepalive 5 ;
      '';
    };
    virtualHosts.${nextclouddomain} = {
      forceSSL = true;
      useACMEHost = "web";
      locations."/".proxyPass = "http://nextcloud";
      extraConfig = ''
        client_max_body_size 4G ;
      '';
    };
  };
  guests = let
    mkGuest = guestName: {
      enablePanzer ? false,
      enableRenaultFT ? false,
      enableBunker ? false,
      ...
    }: {
      autostart = true;
      zfs."/state" = {
        pool = "rpool";
        dataset = "local/guests/${guestName}";
      };
      zfs."/persist" = {
        pool = "rpool";
        dataset = "safe/guests/${guestName}";
      };
      zfs."/panzer" = lib.mkIf enablePanzer {
        pool = "panzer";
        dataset = "safe/guests/${guestName}";
      };
      zfs."/renaultft" = lib.mkIf enableRenaultFT {
        pool = "renaultft";
        dataset = "safe/guests/${guestName}";
      };
      zfs."/bunker" = lib.mkIf enableBunker {
        pool = "panzer";
        dataset = "bunker/guests/${guestName}";
      };
      modules = [
        ../../modules/config
        ../../modules/services/${guestName}.nix
        {
          node.secretsDir = ./secrets/${guestName};
          systemd.network.networks."10-${config.guests.${guestName}.networking.mainLinkName}" = {
            DHCP = lib.mkForce "no";
            address = [
              (
                lib.net.cidr.hostCidr config.secrets.secrets.global.net.ips."${config.guests.${guestName}.nodeName}" config.secrets.secrets.global.net.privateSubnet
              )
            ];
            gateway = [(lib.net.cidr.host 1 config.secrets.secrets.global.net.privateSubnet)];
          };
        }
      ];
    };

    #deadnix: skip
    mkMicrovm = guestName: cfg: {
      ${guestName} =
        mkGuest guestName cfg
        // {
          backend = "microvm";
          microvm = {
            system = "x86_64-linux";
            macvtap = "lan";
            baseMac = config.repo.secrets.local.networking.interfaces.lan.mac;
          };
          extraSpecialArgs = {
            inherit (inputs.self) nodes;
            inherit (inputs.self.pkgs.x86_64-linux) lib;
            inherit inputs minimal stateVersion;
          };
        };
    };

    mkContainer = guestName: cfg: {
      ${guestName} =
        mkGuest guestName cfg
        // {
          backend = "container";
          container.macvlan = "lan";
          extraSpecialArgs = {
            inherit lib nodes inputs minimal stateVersion;
          };
        };
    };
  in
    {}
    // mkContainer "adguardhome" {}
    // mkContainer "vaultwarden" {}
    // mkContainer "ddclient" {}
    // mkContainer "nextcloud" {
      enablePanzer = true;
    }
    // mkContainer "gitea" {
      enablePanzer = true;
    }
    // mkContainer "samba" {
      enablePanzer = true;
      enableRenaultFT = true;
    };
}
