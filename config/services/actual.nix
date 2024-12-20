{
  wireguard.services = {
    client.via = "nucnix";
    firewallRuleForNode.nucnix-nginx.allowedTCPPorts = [ 3000 ];
  };
  imports = [ ../actual.nix ];
  services.actual = {
    enable = true;
    settings.port = 3000;
  };
  environment.persistence."/persist".directories = [ { directory = "/var/lib/private/actual"; } ];
}
