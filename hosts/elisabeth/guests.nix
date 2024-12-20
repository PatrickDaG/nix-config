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
      mkGuest =
        guestName:
        {
          enablePanzer ? false,
          enableRenaultFT ? false,
          enableBunker ? false,
          enableSharedPaperless ? false,
          ...
        }:
        {
          autostart = true;
          zfs."/state" = {
            pool = "rpool";
            dataset = "local/guests/${guestName}";
          };
          zfs."/persist" = {
            pool = "rpool";
            dataset = "safe/guests/${guestName}";
          };
          zfs."/panzer" = lib.mkIf enablePanzer {
            pool = "panzer";
            dataset = "safe/guests/${guestName}";
          };
          zfs."/renaultft" = lib.mkIf enableRenaultFT {
            pool = "renaultft";
            dataset = "safe/guests/${guestName}";
          };
          # kinda not necesarry should be removed on next reimaging
          zfs."/bunker" = lib.mkIf enableBunker {
            pool = "panzer";
            dataset = "bunker/guests/${guestName}";
          };
          zfs."/paperless" = lib.mkIf enableSharedPaperless {
            pool = "panzer";
            dataset = "bunker/shared/paperless";
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

      mkContainer = guestName: cfg: {
        ${guestName} = mkGuest guestName cfg // {
          backend = "container";
          container.macvlans = [ "lan-services" ];
          extraSpecialArgs = {
            inherit (inputs.self) nodes globals;
            inherit (inputs.self.pkgs.x86_64-linux) lib;
            inherit inputs minimal stateVersion;
          };
        };
      };
    in
    { }
    // mkContainer "adguardhome" { }
    // mkContainer "oauth2-proxy" { }
    // mkContainer "vaultwarden" { }
    // mkContainer "ddclient" { }
    // mkContainer "ollama" { }
    // mkContainer "murmur" { }
    // mkContainer "homebox" { }
    // mkContainer "invidious" { }
    // mkContainer "ttrss" { }
    // mkContainer "firefly" { }
    // mkContainer "yourspotify" { }
    // mkContainer "netbird" { }
    // mkContainer "blog" { }
    // mkContainer "kanidm" { }
    // mkContainer "nextcloud" { enablePanzer = true; }
    // mkContainer "paperless" { enableSharedPaperless = true; }
    // mkContainer "forgejo" { enablePanzer = true; }
    // mkMicrovm "immich" { enablePanzer = true; }
    // mkContainer "samba" {
      enablePanzer = true;
      enableRenaultFT = true;
      enableBunker = true;
      enableSharedPaperless = true;
    };
}
