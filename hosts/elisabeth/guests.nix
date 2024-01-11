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
in {
  services.nginx = {
    enable = true;
    recommendedSetup = true;
    upstreams.adguardhome = {
      servers."TODO:3000" = {};

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
      servers."TODO:80" = {};

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
      modules = [
        ../../modules/config
        ../../modules/services/${guestName}.nix
        {
          node.secretsDir = ./secrets/${guestName};
          systemd.network.networks."10-${config.guests.${guestName}.networking.mainLinkName}" = {
            DHCP = lib.mkForce "no";
            address = [(lib.net.cidr.host config.secrets.secrets.global.net.ips.${config.guests.${guestName}.nodeName} config.secrets.secrets.global.net.privateSubnet)];
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
    // mkContainer "nextcloud" {
      enablePanzer = true;
    }
    // mkContainer "samba" {
      enablePanzer = true;
      enableRenaultFT = true;
    };
}
