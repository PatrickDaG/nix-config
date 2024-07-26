{ lib, config, ... }:
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
    wait-online.anyInterface = true;
  };
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
}
