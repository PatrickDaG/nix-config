{
  imports = [
    ../../config/basic
    ../../config/optional/initrd-ssh.nix
    ../../config/services/maddy.nix
    ../../config/optional/zfs.nix

    ./net.nix
    ./fs.nix
  ];
  services.xserver = {
    layout = "de";
    xkbVariant = "bone";
  };
  boot.mode = "bios";
  boot.initrd.availableKernelModules = ["virtio_pci" "virtio_net" "virtio_scsi" "virtio_blk"];
  nixpkgs.hostPlatform = "x86_64-linux";
}
