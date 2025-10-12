{
  config,
  ...
}:
{
  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ 80 ];
  };
  globals.wireguard.services-extern.hosts.${config.node.name} = {
    firewallRuleForNode.torweg.allowedTCPPorts = [ 80 ];
  };
  services.nginx = {
    enable = true;
    virtualHosts."blog.lel.lol" = {
      forceSSL = true;
      useACMEHost = "web";
      root = "/var/lib/blog/public";
    };
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/blog";
      user = "blog";
      group = "nginx";
      mode = "0700";
    }
  ];
}
