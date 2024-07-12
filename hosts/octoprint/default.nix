{
  inputs,
  lib,
  ...
}: {
  imports = [
    ../../config/basic
    ../../config/services/octoprint.nix

    inputs.nixos-hardware.nixosModules.raspberry-pi-3
    ./fs.nix
    ./net.nix
  ];
  nixpkgs.hostPlatform = "aarch64-linux";
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  hardware.enableRedistributableFirmware = true;
}
