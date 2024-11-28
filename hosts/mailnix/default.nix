{ pkgs, ... }:
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
    group = "nogroup";
    extraGroups = [ "nix-build" ];
    createHome = false;
  };
  users.groups.nix-build = { };
}
