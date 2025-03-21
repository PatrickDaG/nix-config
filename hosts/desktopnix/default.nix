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

    ../../config/support/bluetooth.nix
    ../../config/support/nintendo.nix
    ../../config/support/nvidia.nix
    ../../config/support/physical.nix
    ../../config/support/pipewire.nix
    ../../config/support/printing.nix
    ../../config/support/secureboot.nix
    ../../config/support/vr.nix
    ../../config/support/yubikey.nix
    ../../config/support/zfs.nix

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
    "rd.luks=no"
    "nvidia-drm.modeset=1"
    # ??????????????
    "nvidia-drm.fbdev=0"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];
  zramSwap.enable = true;

  # Do not cleanup nix store to prevent having to rebuild packages onca a month
  nix.gc.automatic = lib.mkForce false;
  nixpkgs.hostPlatform = "x86_64-linux";

  #nixpkgs.config.cudaSupport = true;

  #programs.streamcontroller.enable = true;
  hardware.opentabletdriver.enable = true;
  topology.self.icon = "devices.desktop";
}
