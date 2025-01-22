{
  config,
  lib,
  globals,
  ...
}:
let
  inherit (lib)
    flip
    mapAttrsToList
    mkMerge
    genAttrs
    attrNames
    ;
in
{
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
  };
  networking.nftables.firewall.zones = genAttrs (attrNames globals.net.vlans) (name: {
    interfaces = [ "lan-${name}" ];
  });
  systemd.network.netdevs = mkMerge (
    flip mapAttrsToList globals.net.vlans (
      name:
      {
        id,
        ...
      }:
      {
        "40-vlan-${name}" = {
          netdevConfig = {
            Name = "vlan-${name}";
            Kind = "vlan";
          };
          vlanConfig.Id = id;
        };
        "50-macvlan-${name}" = {
          netdevConfig = {
            Name = "lan-${name}";
            Kind = "macvlan";
          };
          extraConfig = ''
            [MACVLAN]
            Mode=bridge
          '';
        };
      }
    )
  );
  systemd.network.networks = mkMerge (
    [
      {
        "40-vlans" = {
          matchConfig.Name = "lan01";
          networkConfig.LinkLocalAddressing = "no";
        };
      }
    ]
    ++ (flip mapAttrsToList globals.net.vlans (
      name: _: {
        "40-vlans".vlan = [ "vlan-${name}" ];
        "10-vlan-${name}" = {
          matchConfig.Name = "vlan-${name}";
          # This interface should only be used from attached macvtaps.
          # So don't acquire a link local address and only wait for
          # this interface to gain a carrier.
          networkConfig.LinkLocalAddressing = "no";
          linkConfig.RequiredForOnline = "carrier";
          extraConfig = ''
            [Network]
            MACVLAN=lan-${name}
          '';
        };
        "20-lan-${name}" = {
          DHCP = "yes";
          matchConfig.Name = "lan-${name}";
          networkConfig = {
            IPv6PrivacyExtensions = "yes";
          };
        };
      }
    ))
  );
  networking.nftables.firewall = {
    snippets.nnf-ssh.enable = lib.mkForce false;
    rules = {
      ssh = {
        from = [
          "home"
        ];
        to = [ "local" ];
        allowedTCPPorts = [ 22 ];
      };
      mdns = {
        from = [ "home" ];
        to = [ "local" ];
        allowedUDPPorts = [ 5353 ];
      };
    };
  };

  boot.initrd = {

    availableKernelModules = [
      "8021q"
    ];
    systemd.network = {
      enable = true;
      networks = {
        # redo the network cause the livesystem has macvlans
        "10-lan-home" = {
          DHCP = "yes";
          matchConfig.Name = "vlan-home";
          networkConfig = {
            IPv6PrivacyExtensions = "yes";
          };
        };
        "40-vlans" = {
          matchConfig.MACAddress = config.secrets.secrets.local.networking.interfaces.lan01.mac;
          vlan = [
            "vlan-home"
          ];
        };
      };
      netdevs = {
        "10-vlan-home" = {
          netdevConfig = {
            Name = "vlan-home";
            Kind = "vlan";
          };
          vlanConfig.Id = globals.net.vlans.home.id;
        };
      };
    };
  };

}
