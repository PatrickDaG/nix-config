{
  inputs,
  lib,
  ...
}: {
  imports = [
    ./boot.nix
    ./home-manager.nix
    ./impermanence.nix
    ./inputrc.nix
    ./issue.nix
    ./net.nix
    ./nftables.nix
    ./nix.nix
    ./ssh.nix
    ./system.nix
    ./users.nix
    ./xdg.nix

    ../../users/root

    ../../modules/deterministic-ids.nix
    ../../modules/distributed-config.nix
    ../../modules/meta.nix
    ../../modules/iwd.nix
    ../../modules/secrets.nix
    ../../modules/smb-mounts.nix

    inputs.agenix-rekey.nixosModules.default
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
    inputs.impermanence.nixosModules.impermanence
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nix-topology.nixosModules.default
    inputs.nixos-extra-modules.nixosModules.default
    inputs.nixos-nftables-firewall.nixosModules.default
    inputs.nixvim.nixosModules.nixvim
  ];
  age.identityPaths = ["/state/etc/ssh/ssh_host_ed25519_key"];
  boot.mode = lib.mkDefault "efi";
}
