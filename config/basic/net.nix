{
  lib,
  config,
  ...
}:
{
  globals.wireguard.monitoring.hosts.${config.node.name} = { };

  networking = {
    useNetworkd = true;
    dhcpcd.enable = false;
    useDHCP = false;
    renameInterfacesByMac = lib.mkIf (!config.boot.isContainer) (
      lib.mapAttrs (_: v: v.mac) (config.secrets.secrets.local.networking.interfaces or { })
    );
  };
  systemd.network = {
    enable = true;
    wait-online.enable = false;
  };
  systemd.services.NetworkManager-wait-online.enable = false;
  # systemd resolved does not fully support dnssd
  # Also it isn't yet supported by cups so for printer finding we need avahi
  services.avahi = {
    enable = true;
    ipv4 = true;
    ipv6 = true;
    nssmdns4 = true;
    #nssmdns6 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  # Do not take down the network for too long when upgrading,
  # This also prevents failures of services that are restarted instead of stopped.
  # It will use `systemctl restart` rather than stopping it with `systemctl stop`
  # followed by a delayed `systemctl start`.
  systemd.services.systemd-networkd.stopIfChanged = false;
  # Services that are only restarted might be not able to resolve when resolved is stopped before
  systemd.services.systemd-resolved.stopIfChanged = false;
  services.resolved = {
    enable = true;
    # man I whish dnssec would be viable to use
    dnssec = "false";
    llmnr = "false";
    extraConfig = ''
      MulticastDNS=false
    '';
  };
}
