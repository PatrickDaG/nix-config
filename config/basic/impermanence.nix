{
  config,
  lib,
  pkgs,
  ...
}: let
  onlyHost =
    lib.mkIf (!config.boot.isContainer);
in {
  # to allow all users to access hm managed persistent folders
  programs.fuse.userAllowOther = true;
  services.openssh.hostKeys = lib.mkForce [
    {
      path = "/state/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];
  environment.persistence."/state" = {
    hideMounts = true;

    files =
      [
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ]
      ++ lib.lists.optionals (!config.boot.isContainer)
      [
        "/etc/machine-id"
      ];
    directories = [
      "/var/log"
      "/var/lib/systemd"
      "/var/lib/nixos"
      {
        directory = "/var/tmp/agenix-rekey";
        mode = "0777";
      }
    ];
  };
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [];
  };
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/state".neededForBoot = true;

  # After importing the rpool, rollback the root system to be empty.
  boot.initrd.systemd.services.impermanence-root =
    onlyHost
    {
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
