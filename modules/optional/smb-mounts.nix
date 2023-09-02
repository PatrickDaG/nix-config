userName: {
  pkgs,
  config,
  ...
}: let
  options = [
    "noauto"
    "x-systemd.idle-timeout=60"
    "x-systemd.device-timeout=5s"
    "x-systemd.mount-timeout=5s"
    "credentials=${config.age.secrets.smb-creds.path}"
    "uid=${builtins.toString config.users.users.${userName}.uid}"
    "gid=${builtins.toString config.users.groups.${userName}.gid}"
  ];
in {
  environment.systemPackages = [pkgs.cifs-utils];
  age.secrets.smb-creds.rekeyFile = ../../secrets/smb.cred.age;
  fileSystems = let
    home = "/home/${userName}";
  in {
    "${home}/smb/patri-data" = {
      device = "//192.168.178.2/patri-data";
      fsType = "cifs";
      inherit options;
    };
    "${home}/smb/ggr-data" = {
      device = "//192.168.178.2/patri-paperless";
      fsType = "cifs";
      inherit options;
    };
    "${home}/smb/media" = {
      device = "//192.168.178.2/media";
      fsType = "cifs";
      inherit options;
    };
    "${home}/smb/patri-paperless" = {
      device = "//192.168.178.2/patri-paperless";
      fsType = "cifs";
      inherit options;
    };
  };
}
