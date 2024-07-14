{config, ...}: {
  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [config.services.octoprint.port];
  };
  services.octoprint = {
    port = 3000;
    enable = true;
    plugins = ps: with ps; [ender3v2tempfix costestimation themeify dashboard displaylayerprogress];
    extraConfig = {
      accessControl = {
        addRemoteUser = true;
        trustRemoteUser = true;
        remoteUserHeader = "X-User";
      };
    };
  };
}
