{inputs, ...}: {
  imports = [
    ./boot.nix
    ./efi.nix
    ./home-manager.nix
    ./inputrc.nix
    ./issue.nix
    ./net.nix
    ./nix.nix
    ./ssh.nix
    ./system.nix
    ./users.nix
    ./xdg.nix
    ./usbguard.nix

    ../../users/root

    ../secrets.nix
    ../meta.nix
    ../smb-mounts.nix
    ../deterministic-ids.nix
    ./impermanence

    inputs.home-manager.nixosModules.default
    inputs.impermanence.nixosModules.impermanence
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.nixseparatedebuginfod.nixosModules.default
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nixvim.nixosModules.nixvim
    inputs.nixos-extra-modules.nixosModules.default
  ];
  age.identityPaths = ["/state/etc/ssh/ssh_host_ed25519_key"];
}
