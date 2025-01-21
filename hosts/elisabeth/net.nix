{
  config,
  lib,
  ...
}:
{
  networking = {
    inherit (config.secrets.secrets.local.networking) hostId;
  };
  networking.nftables.firewall = {
    snippets.nnf-ssh.enable = lib.mkForce false;
    rules = {
      ssh = {
        from = [
          "home"
        ];
        to = [ "local" ];
        allowedTCPPorts = [ 22 ];
      };
      mdns = {
        from = [ "home" ];
        to = [ "local" ];
        allowedUDPPorts = [ 5353 ];
      };
    };
  };

}
