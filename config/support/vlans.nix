{
  globals,
  lib,
  utils,
  config,
  ...
}:
let
  inherit (lib)
    mkMerge
    flip
    mapAttrsToList
    genAttrs
    attrNames
    ;
in
{
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
        "50-bridge-${name}" = {
          netdevConfig = {
            Name = "br-${name}";
            Kind = "bridge";
          };
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
      name:
      {
        cidrv4,
        cidrv6,
        ...
      }:
      {
        "40-vlans".vlan = [ "vlan-${name}" ];
        "10-vlan-${name}" = {
          matchConfig.Name = "vlan-${name}";
          # This interface should only be used from attached macvtaps.
          # So don't acquire a link local address and only wait for
          # this interface to gain a carrier.
          networkConfig.LinkLocalAddressing = "no";
          linkConfig.RequiredForOnline = "carrier";
          networkConfig = {
            Bridge = "br-${name}";
          };
        };
        "10-${name}" = {
          matchConfig.Name = "br-${name}";
          networkConfig.LinkLocalAddressing = "no";
          linkConfig.RequiredForOnline = "carrier";
          networkConfig = {
            MACVLAN = "lan-${name}";
          };
        };
        "20-lan-${name}" = {
          address = [
            (lib.net.cidr.hostCidr 1 cidrv4)
            (lib.net.cidr.hostCidr 1 cidrv6)
          ];
          matchConfig.Name = "lan-${name}";
          networkConfig = {
            IPv6PrivacyExtensions = "yes";
            IPv4Forwarding = "yes";
            IPv6SendRA = true;
            IPv6AcceptRA = false;
            DHCPPrefixDelegation = true;
          };
          ipv6Prefixes = [
            { Prefix = cidrv6; }
          ];
        };
      }
    ))
  );
  systemd.services.nftables.after = flip mapAttrsToList globals.net.vlans (
    name: _: "sys-subsystem-net-devices-${utils.escapeSystemdPath "lan-${name}"}.device"
  );
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
