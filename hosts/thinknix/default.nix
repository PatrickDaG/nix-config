{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
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
    ../../config/support/nix-builder.nix
    ../../config/support/physical.nix
    ../../config/support/pipewire.nix
    ../../config/support/printing.nix
    ../../config/support/secureboot.nix
    ../../config/support/yubikey.nix
    ../../config/support/zfs.nix
    #keep-sorted end

    ./net.nix
    ./fs.nix

    ../../users/patrick
  ];

  hardware.trackpoint.enable = lib.mkDefault true;
  hardware.trackpoint.emulateWheel = lib.mkDefault config.hardware.trackpoint.enable;

  # Fingerprint reader: login and unlock with fingerprint (if you add one with `fprintd-enroll`)
  # services.fprintd.enable = true;
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

  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };
  environment.persistence."/state".directories = [
    "/var/lib/fprint"
  ];

  #services.thinkfan.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";
  nix.settings.system-features = [
    "kvm"
    "nixos-test"
  ];
  topology.self.icon = "devices.laptop";
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];
}
