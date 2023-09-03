{lib, ...}: {
  networking = {
    useNetworkd = true;
    dhcpcd.enable = false;
    # allow mdns port
    firewall.allowedUDPPorts = [5353];
  };
  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;
  };
  system.nssDatabases.hosts = lib.mkMerge [
    (lib.mkBefore ["mdns_minimal [NOTFOUND=return]"])
    (lib.mkAfter ["mdns"])
  ];
  services.resolved = {
    enable = true;
    # man I whish dnssec would be viable to use
    dnssec = "allow-downgrade";
    llmnr = "false";
    extraConfig = ''
      Domains=~.
      MulticastDNS=true
    '';
  };
}
