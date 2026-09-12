{
  config,
  inputs,
  lib,
  minimal,
  ...
}:
{
  guests = lib.genAttrs [ "homeassistant" "esphome" "nginx" ] (guestName: {
    backend = "container";
    autostart = true;
    container.macvlans = [ "lan-house:mv-house" ];
    zfs = {
      "/state" = {
        pool = "rpool";
        dataset = "local/guests/${guestName}";
      };
      "/persist" = {
        pool = "rpool";
        dataset = "safe/guests/${guestName}";
      };
    };
    extraSpecialArgs = {
      inherit (inputs.self) nodes globals;
      inherit (inputs.self.pkgs.x86_64-linux) lib;
      inherit inputs minimal;
    };
    modules = [
      ../../config/basic
      ./${guestName}.nix
      inputs.microvm.nixosModules.microvm-options
      {
        node.secretsDir = config.node.secretsDir + "/${guestName}";
        networking.nftables.firewall.zones.untrusted.interfaces = [ "mv-house" ];
        systemd.network.networks."10-mv-house" = lib.mkIf (guestName == "nginx") {
          DHCP = lib.mkForce "no";
          address = [
            "192.168.178.6/24"
            "fd7a:3539:5f0e:0::6/64"
          ];
          gateway = [
            "192.168.178.1"
            "fd7a:3539:5f0e:0::1"
          ];
        };
      }
    ];
  });
}
