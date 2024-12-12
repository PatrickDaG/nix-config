{
  imports = [
    ../../config/basic
    ../../config/support/initrd-ssh.nix
    # ../../config/services/maddy.nix
    ../../config/support/zfs.nix

    ./net.nix
    ./fs.nix
  ];
  boot.mode = "bios";
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_net"
    "virtio_scsi"
    "virtio_blk"
  ];
  nixpkgs.hostPlatform = "x86_64-linux";
  topology.self.icon = "devices.cloud-server";
}
