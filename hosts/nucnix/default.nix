{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../config/basic
    ../../config/support/initrd-ssh.nix
    ../../config/support/physical.nix
    #../../config/support/secureboot.nix
    ../../config/support/server.nix
    ../../config/support/zfs.nix

    ./net.nix
    ./fs.nix
  ];
  services.xserver = {
    xkb = {
      layout = "de";
    };
  };
  nixpkgs.hostPlatform = "x86_64-linux";
  topology.self.icon = "devices.cloud-server";
}
