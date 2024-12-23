{
  config,
  lib,
  pkgs,
  ...
}:
let
  onlyHost = lib.mkIf (
    !config.boot.isContainer && !(config ? microvm.guest && config.microvm.guest.enable)
  );
  prune =
    folder:
    pkgs.writers.writePython3Bin "impermanence-prune" { } ''
      import os
      import sys
      mounts = [${
        lib.concatStringsSep ", " (
          (map (
            x: "\"" + (if x.home != null then x.home + "/" else "") + x.directory + "\""
          ) config.environment.persistence.${folder}.directories)
          ++ (map (
            x: "\"" + (if x.home != null then x.home + "/" else "") + x.file + "\""
          ) config.environment.persistence.${folder}.files)
        )
      }]  # noqa: E501
      mounts = [os.path.normpath(x) for x in mounts]
      mounts.sort()
      real_mounts = mounts[:1]
      for i in mounts[1:]:
          if i.startswith(real_mounts[-1] + "/"):
              continue
          real_mounts.append(i)
      erg = set()
      for i in real_mounts:
          dir = os.path.dirname(i)
          try:
              content = [dir + "/" + x for x in os.listdir("${folder}" + dir)]
              for j in content:
                  if not any([x.startswith(j) for x in real_mounts]):
                      erg.add("${folder}" + j)
          except PermissionError:
              print(f"{dir} could not be accessed. Try running as root",
                    file=sys.stderr)
      print("\n".join(erg))
    '';
in
{
  # https://github.com/nix-community/impermanence/issues/229
  boot.initrd.systemd.suppressedUnits = [ "systemd-machine-id-commit.service" ];
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
  # to allow all users to access hm managed persistent folders
  lib.scripts.impermanence.pruneScripts = lib.mapAttrs (k: _: prune k) config.environment.persistence;
  programs.fuse.userAllowOther = true;
  services.openssh.hostKeys = lib.mkForce [
    {
      path = "/state/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];
  environment.persistence."/state" = {
    hideMounts = true;

    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ] ++ lib.lists.optionals (!config.boot.isContainer) [ "/etc/machine-id" ];
    directories = [
      "/var/log"
      "/var/lib/systemd"
      "/var/lib/nixos"
      {
        directory = "/var/tmp/nix-import-encrypted/";
        mode = "0777";
      }
      {
        directory = "/var/tmp/agenix-rekey";
        mode = "0777";
      }
    ];
  };
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [ ];
  };
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/state".neededForBoot = true;

  # After importing the rpool, rollback the root system to be empty.
  boot.initrd.systemd.services.impermanence-root = onlyHost {
    wantedBy = [ "initrd.target" ];
    after = [ "zfs-import-rpool.service" ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.zfs}/bin/zfs rollback -r rpool/local/root@blank";
    };
  };
}
