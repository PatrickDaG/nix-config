{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc
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
  };
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  services.logkeys = {
    enable = true;
    device = "/dev/input/event15";
  };

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];
  nix.settings.system-features = [
    "kvm"
    "nixos-test"
  ];
  boot.kernelParams = lib.mkForce [
    "rd.luks.options=timeout=0"
    "rootflags=x-systemd.device-timeout=0"
    "nohibernate"
    "root=fstab"
    "loglevel=4"
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];
  zramSwap.enable = true;

  services.netbird.enable = true;
  # Do not cleanup nix store to prevent having to rebuild packages onca a month
  nix.gc.automatic = lib.mkForce false;
  nixpkgs.hostPlatform = "x86_64-linux";

  #nixpkgs.config.cudaSupport = true;

  programs.streamcontroller.enable = true;
  hardware.opentabletdriver.enable = true;
}
