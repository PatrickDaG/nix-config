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

    #keep-sorted start
    ../../config/support/bluetooth.nix
    ../../config/support/nintendo.nix
    ../../config/support/nix-builder.nix
    ../../config/support/nvidia.nix
    ../../config/support/physical.nix
    ../../config/support/pipewire.nix
    ../../config/support/printing.nix
    ../../config/support/secureboot.nix
    ../../config/support/vr.nix
    ../../config/support/wine.nix
    ../../config/support/yubikey.nix
    ../../config/support/zfs.nix
    #keep-sorted end

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
  i18n.supportedLocales = [ "all" ];
  # No one knows which is better
  # https://linuxblog.io/zswap-better-than-zram/
  # https://linuxreviews.org/Zram
  # I just like zswap more
  #zramSwap.enable = true;
  boot.kernelParams = [
    "zswap.enabled=1" # enables zswap
    "zswap.compressor=zstd" # compression algorithm
    "zswap.max_pool_percent=30" # maximum percentage of RAM that zswap is allowed to use
    "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
  ];

  # Do not cleanup nix store to prevent having to rebuild packages onca a month
  nix.gc.automatic = lib.mkForce false;
  nixpkgs.hostPlatform = "x86_64-linux";

  #nixpkgs.config.cudaSupport = true;

  #programs.streamcontroller.enable = true;
  hardware.opentabletdriver.enable = true;
  topology.self.icon = "devices.desktop";
}
