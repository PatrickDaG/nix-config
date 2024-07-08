{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    # for some reasons the cpu-intel includes the gpu as well
    # for just cpu you should include cpu-intel/cpu-only.nix
    #inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd

    ../../config/basic

    ../../config/hardware/bluetooth.nix
    ../../config/hardware/laptop.nix
    ../../config/hardware/nvidia.nix
    ../../config/hardware/physical.nix
    ../../config/hardware/pipewire.nix
    ../../config/hardware/prime-offload.nix
    ../../config/hardware/yubikey.nix

    ../../config/optional/dev.nix
    ../../config/optional/graphical.nix
    ../../config/optional/printing.nix
    ../../config/optional/secureboot.nix
    ../../config/optional/steam.nix
    ../../config/optional/wayland.nix
    ../../config/optional/zfs.nix

    ./net.nix
    ./fs.nix

    ../../users/patrick
  ];
  stylix.fonts.sizes = {
    terminal = 9;
    applications = 9;
    desktop = 8;
  };
  hidpi = true;
  services = {
    xserver.xkb = {
      layout = "de";
      variant = "bone";
    };
    libinput = {
      touchpad = lib.mkForce {
        accelSpeed = "0.5";
      };
    };
  };
  nixpkgs.hostPlatform = "x86_64-linux";
  nix.settings.system-features = ["kvm" "nixos-test"];
}
