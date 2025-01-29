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
        internet = false;
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
        ip = 10;
      };
      forgejo = {
        domain = "forge.${globals.domains.web}";
        ip = 13;
      };
      immich = {
        domain = "immich.${globals.domains.web}";
      };
      nextcloud = {
        domain = "nc.${globals.domains.web}";
      };
      ollama = {
        domain = "ai.${globals.domains.web}";
      };
      paperless = {
        domain = "ppl.${globals.domains.web}";
      };
      fritz = {
        domain = "fritz.${globals.domains.web}";
      };
      ttrss = {
        domain = "rss.${globals.domains.web}";
      };
      vaultwarden = {
        domain = "pw.${globals.domains.web}";
      };
      yourspotify = {
        domain = "sptfy.${globals.domains.web}";
      };
      apispotify = {
        domain = "apisptfy.${globals.domains.web}";
      };
      kanidm = {
        domain = "auth.${globals.domains.web}";
      };
      oauth2-proxy = {
        domain = "oauth2.${globals.domains.web}";
      };
      actual = {
        domain = "actual.${globals.domains.web}";
      };
      firefly = {
        domain = "money.${globals.domains.web}";
      };
      homebox = {
        domain = "homebox.${globals.domains.web}";
      };
      invidious = {
        domain = "yt.${globals.domains.web}";
      };
      blog = {
        domain = "blog.${globals.domains.web}";
      };
      netbird = {
        domain = "netbird.${globals.domains.web}";
        ip = 16;
      };
      grafana = {
        domain = "grafana.${globals.domains.web}";
      };
      loki = {
        domain = "loki.${globals.domains.web}";
      };
      influxdb = {
        domain = "influxdb.${globals.domains.web}";
      };
      nginx = {
        domain = globals.domains.web;
        ip = 5;
      };
      samba = {
        domain = "smb.${globals.domains.web}";
        ip = 12;
      };
      ddclient = {
      };
      hostapd = {
        ip = 19;
      };
      teamspeak = {
        domain = "ts.${globals.domains.web}";
        ip = 9;
      };
      homeassistant = {
        domain = "hs.${globals.domains.web}";
      };
      esphome = {
        domain = "esp.${globals.domains.web}";
      };
    };
  };
}
