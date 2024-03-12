{
  lib,
  minimal,
  ...
}: {
  imports =
    [
      ../../modules/config
      ../../modules/optional/initrd-ssh.nix
      ../../modules/services/maddy.nix

      ../../modules/hardware/zfs.nix

      ./net.nix
      ./fs.nix
    ]
    ++ lib.lists.optionals (!minimal) [
    ];
  services.xserver = {
    layout = "de";
    xkbVariant = "bone";
  };
  boot.mode = "bios";
  boot.initrd.availableKernelModules = ["virtio_pci" "virtio_net" "virtio_scsi" "virtio_blk"];
  nixpkgs.config.permittedInsecurePackages = lib.trace "remove when possible" [
    "nix-2.16.2"
  ];
}
