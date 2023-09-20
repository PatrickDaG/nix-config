{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd

    ../../modules/config
    ../../modules/dev

    ../../modules/hardware/bluetooth.nix
    ../../modules/hardware/laptop.nix
    ../../modules/hardware/intel.nix
    ../../modules/hardware/nvidia.nix
    ../../modules/hardware/physical.nix
    ../../modules/hardware/pipewire.nix
    ../../modules/hardware/yubikey.nix
    ../../modules/hardware/zfs.nix

    ../../modules/hardware/prime-offload.nix

    ./net.nix
    ./fs.nix
    ./wireguard.nix

    ../../users/patrick
  ];
}
