{
  imports = [../../modules/homebox.nix];
  wireguard.elisabeth = {
    client.via = "elisabeth";
    firewallRuleForNode.elisabeth.allowedTCPPorts = [3000];
  };
  services.homebox = {
    enable = true;
    settings = {
      HBOX_WEB_PORT = "3000";
    };
  };
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/homebox";
      user = "homebox";
      group = "homebox";
      mode = "750";
    }
  ];
}
