{ globals, lib, ... }:
let
  inherit (lib)
    concatStringsSep
    net
    toUpper
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
              "iifname { vlan-fritz, lan-home } ip daddr { ${net.cidr.host 1 globals.net.vlans.services.cidrv4}, ${net.cidr.host 2 "10.99.2.0/24"} } ${protocol} dport { ${concatStringsSep ", " (map toString ports)} } dnat ip to ${
                net.cidr.host globals.services.${service}.ip globals.net.vlans.services.cidrv4
              }${optionalString (fport != null) ":${toString fport}"}"
              "iifname { vlan-fritz, lan-home } ip6 daddr ${net.cidr.host 1 globals.net.vlans.services.cidrv6} ${protocol} dport { ${concatStringsSep ", " (map toString ports)} } dnat ip6 to ${
                net.cidr.host globals.services.${service}.ip globals.net.vlans.services.cidrv6
              }${optionalString (fport != null) ":${toString fport}"}"
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
              "allowed${toUpper protocol}Ports" = if fport != null then [ fport ] else ports;
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
  # quic
  (forward {
    service = "nginx";
    ports = [
      443
    ];
    protocol = "udp";
  })
  (forward {
    service = "forgejo";
    ports = [
      9922
    ];
    protocol = "tcp";
    fport = 22;
  })
  (forward {
    service = "teamspeak";
    ports = [
      9987
    ];
    protocol = "udp";
  })
  # (forward {
  #   service = "netbird";
  #   ports = [
  #     3478
  #     5349
  #   ];
  #   protocol = "udp";
  # })
  (forward {
    service = "headscale";
    ports = [
      # headscale stun
      3478
      # tailscale
      41641
    ];
    protocol = "udp";
  })
]
