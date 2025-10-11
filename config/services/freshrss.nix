{ config, pkgs, ... }:
{
  globals.services.freshrss.host = config.node.name;
  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ 80 ];
  };
  globals.wireguard.services-extern.hosts.${config.node.name} = {
    firewallRuleForNode.torweg.allowedTCPPorts = [ 80 ];
  };
  services.freshrss = {
    enable = true;
    defaultUser = "patrick";
    baseUrl = "https://rss.lel.lol";
    virtualHost = "rss.lel.lol";
    authType = "none";
    extensions = [ pkgs.freshrss-extensions.youtube ];
  };
  environment.persistence."/persist".directories = [
    {
      inherit (config.services.freshrss) user;
      directory = config.services.freshrss.dataDir;
      group = config.services.freshrss.user;
      mode = "0750";
    }
  ];
}
