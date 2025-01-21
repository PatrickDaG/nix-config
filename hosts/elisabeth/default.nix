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
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate

    ../../config/basic

    ../../config/support/initrd-ssh.nix
    ../../config/support/physical.nix
    ../../config/support/secureboot.nix
    ../../config/support/server.nix
    ../../config/support/zfs.nix
    ../../config/support/vlans.nix

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
}
