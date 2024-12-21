{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (config) globals;
  # Try to access the extra builtin we loaded via nix-plugins.
  # Throw an error if that doesn't exist.
  rageImportEncrypted =
    assert lib.assertMsg (builtins ? extraBuiltins.rageImportEncrypted)
      "The extra builtin 'rageImportEncrypted' is not available, so repo.secrets cannot be decrypted. Did you forget to add nix-plugins and point it to `./nix/extra-builtins.nix` ?";
    builtins.extraBuiltins.rageImportEncrypted;
in
{
  imports = [
    (rageImportEncrypted inputs.self.secretsConfig.masterIdentities ./secrets/global.nix.age)
  ];
  globals = {
    net.vlans = {
      home = rec {
        id = 10;
        cidrv4 = "10.99.${toString id}.0/24";
        cidrv6 = "fd${toString id}::/64";
      };
      services = rec {
        id = 20;
        cidrv4 = "10.99.${toString id}.0/24";
        cidrv6 = "fd${toString id}::/64";
      };
      devices = rec {
        id = 30;
        cidrv4 = "10.99.${toString id}.0/24";
        cidrv6 = "fd${toString id}::/64";
      };
      iot = rec {
        id = 40;
        cidrv4 = "10.99.${toString id}.0/24";
        cidrv6 = "fd${toString id}::/64";
      };
      guests = rec {
        id = 50;
        cidrv4 = "10.99.${toString id}.0/24";
        cidrv6 = "fd${toString id}::/64";
      };
    };
    services = {
      adguardhome = {
        domain = "adguardhome.${globals.domains.web}";
        host = "nucnix-adguardhome";
        ip = 10;
      };
      forgejo = {
        domain = "forge.${globals.domains.web}";
        host = "elisabeth-forgejo";
        ip = 13;
      };
      immich = {
        domain = "immich.${globals.domains.web}";
        host = "elisabeth-immich";
      };
      nextcloud = {
        domain = "nc.${globals.domains.web}";
        host = "elisabeth-nextcloud";
      };
      ollama = {
        domain = "ai.${globals.domains.web}";
        host = "elisabeth-ollama";
      };
      paperless = {
        domain = "ppl.${globals.domains.web}";
        host = "elisabeth-paperless";
      };
      ttrss = {
        domain = "rss.${globals.domains.web}";
        host = "elisabeth-ttrss";
      };
      vaultwarden = {
        domain = "pw.${globals.domains.web}";
        host = "elisabeth-vaultwarden";
      };
      yourspotify = {
        domain = "sptfy.${globals.domains.web}";
        host = "elisabeth-yourspotify";
      };
      apispotify = {
        domain = "apisptfy.${globals.domains.web}";
        host = "elisabeth-yourspotify";
      };
      kanidm = {
        domain = "auth.${globals.domains.web}";
        host = "elisabeth-kanidm";
      };
      oauth2-proxy = {
        domain = "oauth2.${globals.domains.web}";
        host = "elisabeth-oauth2-proxy";
      };
      actual = {
        domain = "actual.${globals.domains.web}";
        host = "elisabeth-actual";
      };
      firefly = {
        domain = "money.${globals.domains.web}";
        host = "elisabeth-firefly";
      };
      homebox = {
        domain = "homebox.${globals.domains.web}";
        host = "elisabeth-homebox";
      };
      invidious = {
        domain = "yt.${globals.domains.web}";
        host = "elisabeth-invidious";
      };
      blog = {
        domain = "blog.${globals.domains.web}";
        host = "elisabeth-blog";
      };
      netbird = {
        domain = "netbird.${globals.domains.web}";
        host = "elisabeth-netbird";
        ip = 16;
      };
      nginx = {
        domain = globals.domains.web;
        host = "nucnix-nginx";
        ip = 5;
      };
      samba = {
        domain = "smb.${globals.domains.web}";
        host = "elisabeth-samba";
        ip = 12;
      };
      ddclient = {
        domain = "";
        host = "elisabeth-ddclient";
      };
      murmur = {
        domain = "ts.${globals.domains.web}";
        host = "elisabeth-murmur";
        ip = 9;
      };
    };
  };
}
