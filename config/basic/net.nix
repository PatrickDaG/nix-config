{
  lib,
  config,
  globals,
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
    settings.Resolve = {
      MulticastDNS = false;
      LLMNR = "false";
      # man I whish dnssec would be viable to use
      DNSSEC = "false";
      DNSOverTLS = "yes";
      DNS =
        let
          id = globals.net.dns.default;
          # Split the 6-character ID into two parts: first 2 chars and last 4 chars
          part1 = builtins.substring 0 2 id;
          part2 = builtins.substring 2 4 id;
          ip = [
            "2a07:a8c0::${part1}:${part2}"
            "2a07:a8c1::${part1}:${part2}"
            "45.90.28.138"
            "45.90.30.138"
          ];
          dns = "${id}.dns.nextdns.io";
        in
        lib.flip lib.map ip (ip: "${ip}#${config.node.name}-${dns}");
    };
  };
}
