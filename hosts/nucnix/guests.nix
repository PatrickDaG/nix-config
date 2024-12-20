{
  config,
  stateVersion,
  inputs,
  lib,
  minimal,
  ...
}:
{
  guests =
    let
      mkGuest = guestName: _: {
        autostart = true;
        zfs."/state" = {
          pool = "rpool";
          dataset = "local/guests/${guestName}";
        };
        zfs."/persist" = {
          pool = "rpool";
          dataset = "safe/guests/${guestName}";
        };
        modules = [
          ../../config/basic
          ../../config/services/${guestName}.nix
          {
            node.secretsDir = config.node.secretsDir + "/${guestName}";
            networking.nftables.firewall.zones.untrusted.interfaces = lib.mkIf (
              lib.length config.guests.${guestName}.networking.links == 1
            ) config.guests.${guestName}.networking.links;
          }
        ];
      };

      mkMicrovm = guestName: cfg: {
        ${guestName} = mkGuest guestName cfg // {
          backend = "microvm";
          microvm = {
            system = "x86_64-linux";
            interfaces.lan = { };
            baseMac = config.secrets.secrets.local.networking.interfaces.lan01.mac;
          };
          extraSpecialArgs = {
            inherit (inputs.self) nodes globals;
            inherit (inputs.self.pkgs.x86_64-linux) lib;
            inherit inputs minimal stateVersion;
          };
        };
      };

      mkContainer =
        guestName:
        {
          macvlans ? [ "lan-services" ],
          ...
        }@cfg:
        {
          ${guestName} = mkGuest guestName cfg // {
            backend = "container";
            container.macvlans = macvlans;
            extraSpecialArgs = {
              inherit (inputs.self) nodes globals;
              inherit (inputs.self.pkgs.x86_64-linux) lib;
              inherit inputs minimal stateVersion;
            };
          };
        };
    in
    { }
    // mkContainer "adguardhome" { macvlans = [ "lan-services" ]; }
    // mkContainer "nginx" { macvlans = [ "lan-services" ]; };
}
