{ inputs, lib, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    # for some reasons the cpu-intel includes the gpu as well
    # for just cpu you should include cpu-intel/cpu-only.nix
    #inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd

    ../../config/basic

    #keep-sorted start
    ../../config/support/bluetooth.nix
    ../../config/support/laptop.nix
    ../../config/support/nvidia.nix
    ../../config/support/physical.nix
    ../../config/support/pipewire.nix
    ../../config/support/prime-offload.nix
    ../../config/support/printing.nix
    ../../config/support/secureboot.nix
    ../../config/support/yubikey.nix
    ../../config/support/wine.nix
    ../../config/support/zfs.nix
    #keep-sorted end

    ./net.nix
    ./fs.nix

    ../../users/patrick
  ];
  stylix.fonts.sizes = {
    terminal = 9;
    applications = 9;
    desktop = 8;
  };
  services = {
    xserver.xkb = {
      layout = "de";
    };
    libinput = {
      touchpad = lib.mkForce { accelSpeed = "0.5"; };
    };
  };
  nixpkgs.hostPlatform = "x86_64-linux";
  nix.settings.system-features = [
    "kvm"
    "nixos-test"
  ];
  topology.self.icon = "devices.laptop";
}
