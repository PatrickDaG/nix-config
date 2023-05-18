{nodeName, ...}: {
  networking = {
    useNetworkd = true;
    dhcpcd.enable = false;
    hostName = nodeName;
  };
  # Should remain enabled since nscd from glibc is kinda ass
  services.nscd.enableNsncd = true;
  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;
  };
  services.resolved = {
    enable = true;
    # man i whish dnssec would be viable to use
    dnssec = "allow-downgrade";
    llmnr = "true";
  };
}
