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
              data = "${net.cidr.host globals.services.adguardhome.ip globals.net.vlans.services.cidrv4}";
            }
          ];
          reservations = [
          ];
        }
      );
    };
  };

  systemd.services.kea-dhcp4-server.after = flip mapAttrsToList vlans (
    name: _: "sys-subsystem-net-devices-${utils.escapeSystemdPath "lan-${name}"}.device"
  );
}
