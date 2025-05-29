{ inputs, lib, ... }:
{
  imports = [
    # keep-sorted start
    ./boot.nix
    ./generate-installer-package.nix
    ./home-manager.nix
    ./impermanence.nix
    ./inputrc.nix
    ./issue.nix
    ./net.nix
    ./nftables.nix
    ./nix.nix
    ./promtail.nix
    ./secrets.nix
    ./ssh.nix
    ./system.nix
    ./telegraf.nix
    ./users.nix
    ./xdg.nix
    # keep-sorted end

    ../../users/root

    # keep-sorted start
    ../../modules/deterministic-ids.nix
    ../../modules/distributed-config.nix
    ../../modules/ensure-pcr.nix
    ../../modules/iwd.nix
    ../../modules/meta.nix
    ../../modules/nginx-monitor.nix
    ../../modules/secrets.nix
    ../../modules/smb-mounts.nix
    # keep-sorted end

    # keep-sorted start
    inputs.agenix-rekey.nixosModules.default
    inputs.agenix.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.elewrap.nixosModules.default
    inputs.home-manager.nixosModules.default
    inputs.idmail.nixosModules.default
    inputs.impermanence.nixosModules.impermanence
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.niri.nixosModules.niri
    inputs.nix-gaming.nixosModules.platformOptimizations
    inputs.nix-topology.nixosModules.default
    #inputs.lix-module.nixosModules.default
    inputs.nixos-nftables-firewall.nixosModules.default
    inputs.nixpkgs-xr.nixosModules.nixpkgs-xr
    inputs.nixvim.nixosModules.nixvim
    inputs.stylix.nixosModules.stylix
    # keep-sorted end
  ];
  age.identityPaths = [ "/state/etc/ssh/ssh_host_ed25519_key" ];
  boot.mode = lib.mkDefault "efi";
  documentation.enable = lib.mkDefault false;
}
