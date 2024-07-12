{config, ...}: {
  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [config.services.octoprint.port];
  };
  networking.firewall.allowedTCPPorts = [3000];
  services.octoprint = {
    port = 3000;
    enable = true;
    extraConfig = {
      accessControl = {
        addRemoteUser = true;
        trustRemoteUser = true;
      };
    };
  };
}
