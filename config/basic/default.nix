{ inputs, lib, ... }:
{
  imports = [
    ./boot.nix
    ./generate-installer-package.nix
    ./home-manager.nix
    ./impermanence.nix
    ./inputrc.nix
    ./issue.nix
    ./net.nix
    ./nftables.nix
    ./nix.nix
    ./secrets.nix
    ./ssh.nix
    ./system.nix
    ./telegraf.nix
    ./promtail.nix
    ./users.nix
    ./xdg.nix

    ../../users/root

    ../../modules/deterministic-ids.nix
    ../../modules/distributed-config.nix
    ../../modules/ensure-pcr.nix
    ../../modules/meta.nix
    ../../modules/nginx-monitor.nix
    ../../modules/iwd.nix
    ../../modules/secrets.nix
    ../../modules/smb-mounts.nix

    inputs.agenix-rekey.nixosModules.default
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
    inputs.idmail.nixosModules.default
    inputs.impermanence.nixosModules.impermanence
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nix-topology.nixosModules.default
    #inputs.lix-module.nixosModules.default
    inputs.nixos-nftables-firewall.nixosModules.default
    inputs.nixvim.nixosModules.nixvim
    inputs.stylix.nixosModules.stylix
    inputs.elewrap.nixosModules.default
    inputs.nix-gaming.nixosModules.platformOptimizations
  ];
  age.identityPaths = [ "/state/etc/ssh/ssh_host_ed25519_key" ];
  boot.mode = lib.mkDefault "efi";
  documentation.enable = lib.mkDefault false;
}
