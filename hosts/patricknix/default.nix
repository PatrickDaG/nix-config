{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd

    ../../modules/config
    ../../modules/dev
    ../../modules/graphical

    ../../modules/optional/wayland.nix
    ../../modules/optional/secureboot.nix

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
  stylix.fonts.sizes = {
    terminal = 9;
    applications = 9;
    desktop = 8;
  };
  hidpi = true;
}
