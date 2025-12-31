{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  inherit (pkgs.linuxPackages) kernel;
  # Stdenv with a few more LLVM tools available
  llvmKernelStdenv = pkgs.stdenvAdapters.overrideInStdenv pkgs.llvmPackages.stdenv [
    pkgs.llvm
    pkgs.lld
    pkgs.llvmPackages.clang-unwrapped
  ];
in
{
  # boot.kernelPackages = pkgs.linuxPackagesFor (
  #   kernel.override {
  #     # Don't use nixos generic kernel options we do it ourselves
  #     enableCommonConfig = false;
  #     extraMakeFlags = [
  #       # gcc
  #       # "KCFLAGS+=-O3"
  #       # "KCFLAGS+=-mtune=todo"
  #       # "KCFLAGS+=-march=todo"
  #       # Clang/llvm flags
  #       "KCFLAGS+=-O3"
  #       "KCFLAGS+=-mtune=todo"
  #       "KCFLAGS+=-march=todo"
  #       "KCFLAGS+=-Wno-unused-command-line-argument"
  #       "CC=${pkgs.llvmPackages.clang-unwrapped}/bin/clang"
  #       "AR=${pkgs.llvm}/bin/llvm-ar"
  #       "NM=${pkgs.llvm}/bin/llvm-nm"
  #       "LD=${pkgs.lld}/bin/ld.lld"
  #       "LLVM=1"
  #     ];
  #     stdenv = llvmKernelStdenv;
  #     # Config generation failing usually corresponds to your config begin edited
  #     # in the output due to the incompatible options and therefore also failing.
  #     # ignoreConfigErrors = true;
  #
  #     # Start with an all-no config.  It is slightly easiler to pull together
  #     # enough options to get this running than to whittle down the defaults.
  #     # However, it is still a lot and you may miss some that are more important
  #     # than what you gain by starting from a clean slate.
  #     # defconfig = "ARCH=x86_64 allnoconfig";
  #     # This isn't relly used anyway
  #     features = { };
  #     # Don't build everything as a module
  #     autoModules = false;
  #     # I think this is mostly a bad idea
  #     preferBuiltin = false;
  #     structuredExtraConfig = with lib.kernel; {
  #       # Needed by LUKS
  #       CRYPTO_USER_API_AEAD = yes;
  #
  #       # llvm lto
  #       # We are not a k8s server
  #       CPU_MITIGATIONS = lib.mkForce no;
  #
  #       # Clang options require a lot of extra config
  #       CC_IS_CLANG = lib.mkForce yes;
  #       LTO = lib.mkForce yes;
  #       LTO_CLANG = lib.mkForce yes;
  #       # full LTO is much more expsneive
  #       LTO_CLANG_THIN = lib.mkForce yes;
  #     };
  #     kernelPatches = [
  #       # Things that evey kernel should or has to have
  #       (import ./kernel/debug.nix {
  #         inherit lib pkgs;
  #         version = kernel.version;
  #       })
  #     ];
  #   }
  # );
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
