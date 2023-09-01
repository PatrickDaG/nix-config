{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-hdd
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../common/core
    ../common/dev

    ../common/graphical/fonts.nix
    ../common/graphical/steam.nix

    ../common/hardware/bluetooth.nix
    ../common/hardware/intel.nix
    ../common/hardware/nvidia.nix
    ../common/hardware/physical.nix
    ../common/hardware/pipewire.nix
    ../common/hardware/yubikey.nix
    ../common/hardware/zfs.nix

    ./net.nix
    ./fs.nix

    ../../users/patrick
  ];
}
