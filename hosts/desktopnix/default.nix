{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-hdd
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../config/basic

    ../../config/hardware/bluetooth.nix
    ../../config/hardware/nintendo.nix
    ../../config/hardware/nvidia.nix
    ../../config/hardware/physical.nix
    ../../config/hardware/pipewire.nix
    ../../config/hardware/yubikey.nix

    ../../config/optional/dev.nix
    ../../config/optional/graphical.nix
    ../../config/optional/printing.nix
    ../../config/optional/secureboot.nix
    ../../config/optional/steam.nix
    ../../config/optional/xserver.nix
    ../../config/optional/zfs.nix

    ../../modules-hm/streamdeck.nix

    ./net.nix
    ./fs.nix

    ../../users/patrick
  ];
  stylix.fonts.sizes = {
    terminal = 9;
    applications = 10;
    desktop = 10;
  };
  services.xserver.xkb = {
    layout = "de";
    variant = "bone";
  };
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  system.activationScripts.decryptKey.text = ''
    ln -f -s ${../../keys/PatC.key} /run/decrypt.key.pub
  '';
  boot.binfmt.emulatedSystems = ["aarch64-linux" "riscv64-linux"];
  nix.settings.system-features = ["kvm" "nixos-test"];

  services.netbird.enable = true;
  # Do not cleanup nix store to prevent having to rebuild packages onca a month
  nix.gc.automatic = lib.mkForce false;
}
