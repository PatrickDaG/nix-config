{ globals, lib, ... }:
let
  inherit (lib)
    concatStringsSep
    net
    mkMerge
    optionalString
    ;
  forward =
    {
      service,
      ports,
      protocol,
      fport ? null,
      ...
    }:
    {
      networking.nftables = {
        chains = {
          prerouting.port-forward = {
            after = [ "hook" ];
            rules = [
              "iifname lan-home ip daddr { ${net.cidr.host 2 globals.net.vlans.house.cidrv4}, ${net.cidr.host 2 "10.99.2.0/24"} } ${protocol} dport { ${concatStringsSep ", " (map toString ports)} } dnat ip to ${
                net.cidr.host globals.services.${service}.ip globals.net.vlans.house.cidrv4
              }${optionalString (fport != null) ":${toString fport}"}"
              "iifname lan-home ip6 daddr ${net.cidr.host 2 globals.net.vlans.house.cidrv6} ${protocol} dport { ${concatStringsSep ", " (map toString ports)} } dnat ip6 to ${
                net.cidr.host globals.services.${service}.ip globals.net.vlans.house.cidrv6
              }${optionalString (fport != null) ":${toString fport}"}"
            ];
          };
        };
      };
    };
in
mkMerge [
  (forward {
    service = "forgejo";
    ports = [
      9922
    ];
    protocol = "tcp";
    fport = 22;
  })
]
