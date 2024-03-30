{
  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [3000];
  };
  imports = [../actual.nix];
  services.actual = {
    enable = true;
    settings.port = 3000;
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/actual";
    }
  ];
}
