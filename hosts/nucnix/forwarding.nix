{ globals, lib, ... }:
let
  inherit (lib)
    concatStringsSep
    net
    toUpper
    mkMerge
    ;
  forward =
    {
      service,
      ports,
      protocol,
      ...
    }:
    {
      networking.nftables = {
        chains = {
          prerouting.port-forward = {
            after = [ "hook" ];
            rules = [
              "iifname { vlan-fritz, lan-home } ip daddr { ${net.cidr.host 1 globals.net.vlans.services.cidrv4}, ${net.cidr.host 2 "10.99.2.0/24"} } ${protocol} dport { ${concatStringsSep ", " (map toString ports)} } dnat ip to ${
                net.cidr.host globals.services.${service}.ip globals.net.vlans.services.cidrv4
              }"
              "iifname { vlan-fritz, lan-home } ip6 daddr ${net.cidr.host 1 globals.net.vlans.services.cidrv6} ${protocol} dport { ${concatStringsSep ", " (map toString ports)} } dnat ip6 to ${
                net.cidr.host globals.services.${service}.ip globals.net.vlans.services.cidrv6
              }"
            ];
          };
        };
        firewall = {
          zones = {
            ${service}.ipv4Addresses = [
              (lib.net.cidr.host globals.services.${service}.ip globals.net.vlans.services.cidrv4)
            ];
          };
          rules = {
            "forward-${service}" = {
              from = [
                "fritz"
                "home"
              ];
              to = [ service ];
              "allowed${toUpper protocol}Ports" = ports;
            };
          };
        };
      };
    };
in
mkMerge [
  (forward {
    service = "nginx";
    ports = [
      80
      443
    ];
    protocol = "tcp";
  })
  (forward {
    service = "forgejo";
    ports = [
      9922
    ];
    protocol = "tcp";
  })
  (forward {
    service = "murmur";
    ports = [
      9987
    ];
    protocol = "udp";
  })
  (forward {
    service = "netbird";
    ports = [
      3478
      5349
    ];
    protocol = "udp";
  })
]
