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

    ../../modules/config
    ../../modules/dev
    ../../modules/graphical

    ../../modules/optional/wayland.nix
    ../../modules/optional/secureboot.nix
    ../../modules/optional/printing.nix

    ../../modules/hardware/bluetooth.nix
    ../../modules/hardware/laptop.nix
    ../../modules/hardware/nvidia.nix
    ../../modules/hardware/physical.nix
    ../../modules/hardware/pipewire.nix
    ../../modules/hardware/yubikey.nix
    ../../modules/hardware/zfs.nix

    ../../modules/hardware/prime-offload.nix
    ../../modules/optional/steam.nix

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
  services.xserver = {
    xkb = {
      layout = "de";
      variant = "bone";
    };
    libinput = {
      touchpad = lib.mkForce {
        accelSpeed = "0.5";
      };
    };
  };
  system.activationScripts.decryptKey.text = ''
    ln -f -s ${../../keys/PatC.key} /run/decrypt.key.pub
  '';
  nixpkgs.config.permittedInsecurePackages = lib.trace "remove when possible" [
    "nix-2.16.2"
  ];
  services.netbird.enable = true;
}
