{
  lib,
  utils,
  globals,
  ...

}:
let
  inherit (lib)
    net
    flip
    mapAttrsToList
    ;
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
        interfaces = flip mapAttrsToList globals.net.vlans (x: _: "lan-${x}");
      };
      subnet4 = flip mapAttrsToList globals.net.vlans (
        name:
        { id, cidrv4, ... }:
        rec {
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
              data = "${net.cidr.host globals.services.adguardhome.ip globals.net.vlans.services.cidrv4}";
            }
          ];
          reservations = [
            {
              # homematic
              hw-address = "b8:27:eb:5d:ff:36";
              ip-address = net.cidr.host 30 subnet;
            }
            {
              # testberry
              hw-address = "d8:3a:dd:dc:b6:6a";
              ip-address = net.cidr.host 31 subnet;
            }
            {
              # drucker
              hw-address = "48:9e:bd:5c:31:ac";
              ip-address = net.cidr.host 32 subnet;
            }
          ];
        }
      );
    };
  };

  systemd.services.kea-dhcp4-server.after = flip mapAttrsToList globals.net.vlans (
    name: _: "sys-subsystem-net-devices-${utils.escapeSystemdPath "lan-${name}"}.device"
  );
}
