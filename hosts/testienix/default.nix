{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    # TODO: sollte entfernt werden für server
    ../../modules/config
    ../../modules/optional/initrd-ssh.nix

    ../../modules/hardware/intel.nix
    ../../modules/hardware/physical.nix
    ../../modules/hardware/zfs.nix

    ./net.nix
    ./fs.nix
  ];
}
