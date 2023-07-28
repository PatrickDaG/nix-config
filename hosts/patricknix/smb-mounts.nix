{
  pkgs,
  lib,
  config,
  ...
}: let
  options = [
    "noauto"
    "x-systemd.idle-timeout=60"
    "x-systemd.device-timeout=5s"
    "x-systemd.mount-timeout=5s"
    "credentials=${config.age.secrets.smb-creds.path}"
    "uid=${builtins.toString config.users.users.patrick.uid}"
    "gid=${builtins.toString config.users.groups.patrick.gid}"
  ];
in {
  environment.systemPackages = [pkgs.cifs-utils];
  age.secrets.smb-creds.rekeyFile = ../../secrets/smb.cred.age;
  fileSystems = {
    "/mnt/smb/patri-data" = {
      device = "//10.0.0.1/patri-data";
      fsType = "cifs";
      inherit options;
    };
    "/mnt/smb/patri-paperless" = {
      device = "//10.0.0.1/patri-paperless";
      fsType = "cifs";
      inherit options;
    };
  };
}
