{ config, pkgs, ... }:
{
  services.jellyfin = {
    enable = true;
  };
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
  networking.nftables.firewall.zones.untrusted.interfaces = [ "mv-home" ];
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/jellyfin";
      user = "jellyfin";
      group = "jellyfin";
      mode = "0700";
    }
  ];
  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx = {
      # from https://jellyfin.org/docs/general/networking/index.html
      allowedTCPPorts = [
        8096
        8920
      ];
      allowedUDPPorts = [
        1900
        7359
      ];
    };
  };
}
