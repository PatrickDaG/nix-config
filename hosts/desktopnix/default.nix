{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-hdd
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../modules/config
    ../../modules/dev
    ../../modules/graphical

    ../../modules/optional/xserver.nix

    ../../modules/hardware/bluetooth.nix
    ../../modules/hardware/intel.nix
    ../../modules/hardware/nintendo.nix
    ../../modules/hardware/nvidia.nix
    ../../modules/hardware/physical.nix
    ../../modules/hardware/pipewire.nix
    ../../modules/hardware/yubikey.nix
    ../../modules/hardware/zfs.nix

    ../../modules/optional/streamdeck.nix

    ./net.nix
    ./fs.nix

    ../../users/patrick
  ];
  stylix.fonts.sizes = {
    terminal = 10;
    applications = 10;
  };
}
