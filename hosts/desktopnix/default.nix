{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-hdd
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../modules/config
    ../../modules/dev
    ../../modules/graphical

    ../../modules/optional/xserver.nix
    ../../modules/optional/secureboot.nix

    ../../modules/hardware/nintendo.nix
    ../../modules/hardware/nvidia.nix
    ../../modules/hardware/physical.nix
    ../../modules/hardware/pipewire.nix
    ../../modules/hardware/yubikey.nix
    ../../modules/hardware/zfs.nix

    ../../modules/optional/streamdeck.nix
    ../../modules/optional/steam.nix
    ../../modules/optional/printing.nix

    ./net.nix
    ./fs.nix

    ../../users/patrick
  ];
  stylix.fonts.sizes = {
    terminal = 9;
    applications = 10;
    desktop = 10;
  };
  services.xserver = {
    layout = "de";
    xkbVariant = "bone";
  };
  virtualisation.podman = {
    enable = false;
    dockerCompat = true;
  };

  system.activationScripts.decryptKey.text = ''
    ln -f -s ${../../keys/PatC.key} /run/decrypt.key.pub
  '';
  boot.binfmt.emulatedSystems = ["aarch64-linux"];
}
