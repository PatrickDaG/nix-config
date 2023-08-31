{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    # TODO: sollte entfernt werden für server
    ../common/core

    ../common/hardware/intel.nix
    ../common/hardware/physical.nix
    ../common/hardware/zfs.nix

    ./net.nix
    ./fs.nix
  ];
}
