{
  config,
  lib,
  globals,
  ...
}:
{
  imports = [
    ./kea.nix
    ./forwarding.nix
    ./mdns.nix
    ./hostapd.nix
  ];
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.nftables.firewall.zones = {
    fritz.interfaces = [ "vlan-fritz" ];
    wg-services.interfaces = [ "services" ];
    printer.ipv4Addresses = [
      (lib.net.cidr.host 32 globals.net.vlans.devices.cidrv4)
    ];
    smb.ipv4Addresses = [
      (lib.net.cidr.host globals.services.samba.ip globals.net.vlans.home.cidrv4)
    ];
    adguard.ipv4Addresses = [
      (lib.net.cidr.host globals.services.adguardhome.ip globals.net.vlans.services.cidrv4)
    ];
  };
  systemd.network.netdevs = {
    "40-vlan-fritz" = {
      netdevConfig = {
        Name = "vlan-fritz";
        Kind = "vlan";
      };
      vlanConfig.Id = 2;
    };
  };
  systemd.network.networks = {
    "10-lan-fritz" = {
      address = [
        (lib.net.cidr.hostCidr 2 "10.99.2.0/24")
      ];
      gateway = [ (lib.net.cidr.host 1 "10.99.2.0/24") ];
      matchConfig.Name = "vlan-fritz";
      networkConfig = {
        IPv6PrivacyExtensions = "yes";
      };
    };
    "40-vlans" = {
      vlan = [ "vlan-fritz" ];
    };
  };
  networking.nftables.firewall = {
    snippets.nnf-ssh.enable = lib.mkForce false;
    rules = {
      mdns = {
        from = [
          "home"
          "services"
          "devices"
          "guests"
          "iot"
        ];
        to = [ "local" ];
        allowedUDPPorts = [ 5353 ];
      };
      fritz-home-bridge = {
        from = [
          "fritz"
        ];
        to = [ "home" ];
        verdict = "accept";
      };
      printer-smb = {
        from = [
          "printer"
          "fritz"
        ];
        to = [ "smb" ];
        allowedTCPPorts = [ 445 ];
      };
      ssh = {
        from = [
          "fritz"
          "home"
        ];
        to = [ "local" ];
        allowedTCPPorts = [ 22 ];
      };
      services = {
        from = [
          "home"
          "fritz"
        ];
        to = [
          "iot"
          "services"
          "devices"
          "fritz"
        ];
        late = true;
        verdict = "accept";
      };
      dns = {
        from = [
          "home"
          "devices"
          "fritz"
          "guests"
          "services"
        ];
        to = [ "adguard" ];
        allowedUDPPorts = [ 53 ];
      };
      internet = {
        from = [
          "home"
          "devices"
          "guests"
          "services"
        ];
        to = [ "fritz" ];
        late = true;
        verdict = "accept";
        masquerade = true;
      };
      wireguard = {
        from = [ "services" ];
        to = [ "local" ];
        allowedUDPPorts = [ config.wireguard.services.server.port ];
      };
      # Forward traffic between participants
      forward-wireguard = {
        from = [ "wg-services" ];
        to = [ "wg-services" ];
        verdict = "accept";
      };
    };
  };
  wireguard.services.server = {
    host = lib.net.cidr.host 1 "10.99.20.0/24";
    reservedAddresses = [
      "10.42.0.0/20"
      "fd00:1764::/112"
    ];
    openFirewall = true;
  };
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
  };

  boot.initrd = {
    systemd.network = {
      enable = true;
      networks = {
        # redo the network cause the livesystem has macvlans
        "10-lan-fritz" = {
          address = [
            (lib.net.cidr.hostCidr 2 "10.99.2.0/24")
          ];
          gateway = [ (lib.net.cidr.host 1 "10.99.2.0/24") ];
          matchConfig.Name = "vlan-fritz";
          networkConfig = {
            IPv6PrivacyExtensions = "yes";
          };
        };
        "40-vlans" = {
          matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
          vlan = [
            "vlan-fritz"
          ];
        };
      };
      netdevs = {
        "10-vlan-fritz" = {
          netdevConfig = {
            Name = "vlan-fritz";
            Kind = "vlan";
          };
          vlanConfig.Id = 2;
        };
      };
    };
  };
}
