{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd

    ../common/core
    ../common/dev

    ../common/graphical/fonts.nix
    ../common/graphical/steam.nix

    ../common/hardware/bluetooth.nix
    ../common/hardware/intel.nix
    ../common/hardware/laptop.nix
    ../common/hardware/physical.nix
    ../common/hardware/pipewire.nix
    ../common/hardware/yubikey.nix
    ../common/hardware/zfs.nix

    ../common/hardware/nvidia.nix
    ../common/hardware/prime-offload.nix

    ./net.nix
    ./fs.nix
    ./smb-mounts.nix
    ./wireguard.nix

    ../../users/patrick
  ];
}
