{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./users.nix];
  # to allow all users to access hm managed persistent folders
  programs.fuse.userAllowOther = true;
  fileSystems."/state".neededForBoot = true;
  environment.persistence."/state" = {
    hideMounts = true;

    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
    directories =
      [
        "/var/log"
        "/var/lib/systemd"
        "/var/lib/nixos"
        {
          directory = "/var/tmp/agenix-rekey";
          mode = "0777";
        }
      ]
      ++ lib.lists.optionals config.hardware.bluetooth.enable [
        "/var/lib/bluetooth"
      ];
  };

  # After importing the rpool, rollback the root system to be empty.
  boot.initrd.systemd.services.impermanence-root = {
    wantedBy = ["initrd.target"];
    after = ["zfs-import-rpool.service"];
    before = ["sysroot.mount"];
    unitConfig.DefaultDependencies = "no";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.zfs}/bin/zfs rollback -r rpool/local/root@blank";
    };
  };
}
