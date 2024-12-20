{
  wireguard.services = {
    client.via = "nucnix";
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ 3000 ];
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
