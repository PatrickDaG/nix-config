{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd

    ../../config/basic
    ../../config/optional/dev.nix
    ../../config/optional/graphical.nix
    ../../config/optional/wayland.nix
    ../../config/optional/xserver.nix
    ../../config/optional/printing.nix
    ../../config/hardware/bluetooth.nix
    ../../config/hardware/laptop.nix
    ../../config/hardware/physical.nix
    ../../config/hardware/pipewire.nix
    ../../config/hardware/yubikey.nix

    ./net.nix
    ./fs.nix

    ../../users/simon
  ];
  stylix.fonts.sizes = {
    #terminal = 9;
    #applications = 9;
    #desktop = 8;
  };
  services.xserver = {
    layout = "de";
    xkbVariant = "neo";
    libinput = {
      touchpad = lib.mkForce {
        accelSpeed = "0.5";
      };
    };
  };
}
