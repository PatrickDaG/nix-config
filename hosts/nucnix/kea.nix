{
  lib,
  utils,
  ...
}:
let
  inherit (lib)
    net
    flip
    mapAttrsToList
    ;
  vlans = {
    home = 10;
    services = 20;
    devices = 30;
    iot = 40;
    guests = 50;
  };
in
{
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/kea";
      mode = "0700";
    }
  ];

  services.kea.dhcp4 = {
    enable = true;
    settings = {
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      valid-lifetime = 86400;
      renew-timer = 3600;
      interfaces-config = {
        interfaces = flip mapAttrsToList vlans (x: _: "lan-${x}");
      };
      subnet4 = flip mapAttrsToList vlans (
        name: id: rec {
          inherit id;
          interface = "lan-${name}";
          subnet = "10.99.${toString id}.0/24";
          pools = [
            {
              pool = "${net.cidr.host 50 subnet} - ${net.cidr.host (-6) subnet}";
            }
          ];
          option-data = [
            {
              name = "routers";
              data = "${net.cidr.host 1 subnet}";
            }
            {
              name = "domain-name-servers";
              data = "${net.cidr.host 10 subnet}";
            }
          ];
          reservations = [
            #FIXME
            # {
            #   hw-address = nodes.ward-adguardhome.config.lib.microvm.mac;
            #   ip-address = globals.net.home-lan.hosts.ward-adguardhome.ipv4;
            # }
            # {
            #   hw-address = nodes.ward-web-proxy.config.lib.microvm.mac;
            #   ip-address = globals.net.home-lan.hosts.ward-web-proxy.ipv4;
            # }
            # {
            #   hw-address = nodes.sire-samba.config.lib.microvm.mac;
            #   ip-address = globals.net.home-lan.hosts.sire-samba.ipv4;
            # }
          ];
        }
      );
    };
  };

  systemd.services.kea-dhcp4-server.after = [
    "sys-subsystem-net-devices-${utils.escapeSystemdPath "lan-self"}.device"
  ];
}
