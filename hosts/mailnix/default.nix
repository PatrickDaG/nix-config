{ config, pkgs, ... }:
{
  imports = [
    ../../config/basic
    ../../config/support/initrd-ssh.nix
    ../../config/support/zfs.nix
    ../../config/services/idmail.nix
    ../../config/services/stalwart.nix

    ./net.nix
    ./fs.nix
  ];
  boot = {
    initrd.availableKernelModules = [
      "virtio_pci"
      "virtio_net"
      "virtio_scsi"
      "virtio_blk"
      "virtio_gpu"
    ];
    kernelParams = [ "console=tty" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
  nixpkgs.hostPlatform = "aarch64-linux";
  users.users.build = {
    isSystemUser = true;
    shell = pkgs.bash;
    group = "build";
    extraGroups = [ "nix-build" ];
    createHome = false;
    openssh.authorizedKeys.keyFiles = [
      ./secrets/generated/buildSSHKey.pub
    ];
  };

  age.secrets.buildSSHKey = {
    generator.script =
      {
        lib,
        name,
        pkgs,
        file,
        ...
      }:
      ''
        key=$(exec 3>&1; ${pkgs.openssh}/bin/ssh-keygen -q -t ed25519 -N "" -C ${lib.escapeShellArg "${config.networking.hostName}:${name}"} -f /proc/self/fd/3 <<<y >/dev/null 2>&1; true)
        (exec 3<&0; ${pkgs.openssh}/bin/ssh-keygen -f /proc/self/fd/3 -y) <<< "$key" > ${
          lib.escapeShellArg (lib.removeSuffix ".age" file + ".pub")
        }
        echo "$key"
      '';
    intermediary = true;
  };
  users.groups.build = { };
  users.groups.nix-build = { };
}
