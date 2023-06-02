{
  config,
  lib,
  ...
}: {
  # to allow all users to access hm managed persistent folders
  programs.fuse.userAllowOther = true;
  environment.persistence."/state" = {
    hideMounts = true;

    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
    directories =
      [
        {
          directory = "/var/lib/nixos";
          user = "root";
          group = "root";
          mode = "0775";
        }
      ]
      ++ lib.lists.optionals config.hardware.acpilight.enable [
        "/var/lib/systemd/backlight"
      ]
      ++ lib.lists.optionals config.hardware.bluetooth.enable [
        "/var/lib/bluetooth"
      ];
  };
}
