{ config, ... }:
let
  port = 3004;
in
{
  globals.services.atuin.host = config.node.name;
  globals.wireguard.services.hosts.${config.node.name} = {
    firewallRuleForNode.elisabeth-nginx.allowedTCPPorts = [ port ];
  };
  services.atuin = {
    enable = true;
    port = port;
    database.createLocally = true;
    openRegistration = false;
    host = "0.0.0.0";
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/atuin";
      mode = "0750";
    }
  ];
}
