{
  imports = [
    ../../config/basic
    ../../config/support/initrd-ssh.nix
    ../../config/support/zfs.nix

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
}
