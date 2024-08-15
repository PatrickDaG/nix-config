{ config, ... }:
{
  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [ config.services.octoprint.port ];
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/octoprint/";
      user = "octoprint";
      group = "octoprint";
      mode = "750";
    }
  ];
  services.octoprint = {
    port = 3000;
    enable = true;
    plugins = ps: with ps; [ ender3v2tempfix ];
    extraConfig = {
      accessControl = {
        addRemoteUser = true;
        trustRemoteUser = true;
        remoteUserHeader = "X-User";
      };
    };
  };
}
