{
  lib,
  config,
  pkgs,
  ...
}:
{
  networking = {
    useNetworkd = true;
    dhcpcd.enable = false;
    useDHCP = false;
    # allow mdns port
    firewall.allowedUDPPorts = [ 5353 ];
    renameInterfacesByMac = lib.mkIf (!config.boot.isContainer) (
      lib.mapAttrs (_: v: v.mac) (config.secrets.secrets.local.networking.interfaces or { })
    );
  };
  systemd.network = {
    enable = true;
    wait-online.enable = false;
  };
  systemd.services.NetworkManager-wait-online.enable = false;

  # Do not take down the network for too long when upgrading,
  # This also prevents failures of services that are restarted instead of stopped.
  # It will use `systemctl restart` rather than stopping it with `systemctl stop`
  # followed by a delayed `systemctl start`.
  systemd.services.systemd-networkd.stopIfChanged = false;
  # Services that are only restarted might be not able to resolve when resolved is stopped before
  systemd.services.systemd-resolved.stopIfChanged = false;
  system.nssDatabases.hosts = lib.mkMerge [
    (lib.mkBefore [ "mdns_minimal [NOTFOUND=return]" ])
    (lib.mkAfter [ "mdns" ])
  ];
  services.resolved = {
    enable = true;
    # man I whish dnssec would be viable to use
    dnssec = "false";
    llmnr = "false";
    extraConfig = ''
      Domains=~.
      MulticastDNS=true
    '';
  };
  networking.nftables.ruleset = ''
    table inet mdns {
       set OWN_IPS {
         typeof ip saddr
         elements = { 127.0.0.1 }
       }
      chain prerouting {
          type filter hook prerouting priority mangle; policy accept;
          udp dport 5353 ip saddr @OWN_IPS drop;
      }
    }
  '';
  services.networkd-dispatcher = {
    enable = true;
    rules = {
      disable-mdns = {
        onState = [ "configured" ];
        script = ''
          ADDRS=$(${lib.getExe' pkgs.iproute2 "ip"} -j -o addr | ${lib.getExe pkgs.jq} -r ".[] | .addr_info[] | select(.dev != \"lo\") | .local")
          for i in $ADDRS; do
            ${lib.getExe pkgs.nftables} add element inet mdns OWN_IPS "{ $i }"
          done
        '';
      };
    };
  };

}
