{
  inputs,
  minimal,
  lib,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-intel

    ../../config/basic

    ../../config/support/initrd-ssh.nix
    ../../config/support/physical.nix
    ../../config/support/zfs.nix
    ../../config/support/server.nix
    ../../config/support/secureboot.nix

    ./net.nix
    ./fs.nix
  ] ++ lib.lists.optionals (!minimal) [ ./guests.nix ];
  services.xserver = {
    xkb = {
      layout = "de";
    };
  };
  nixpkgs.hostPlatform = "x86_64-linux";

  topology.self.interfaces.lan.network = "home";
  boot = {
    kernelParams = [
      "intel_iommu=on,igx_off,sm_on"
    ];
  };
}
