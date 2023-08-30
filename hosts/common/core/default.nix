{inputs, ...}: {
  imports = [
    ./efi.nix
    ./home-manager.nix
    ./impermanence.nix
    ./inputrc.nix
    ./issue.nix
    ./net.nix
    ./nix.nix
    ./ssh.nix
    ./system.nix
    ./xdg.nix

    ../../../users/root

    ../../../modules/secrets.nix
    ../../../modules/meta.nix

    inputs.home-manager.nixosModules.default
    inputs.impermanence.nixosModules.impermanence
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    inputs.disko.nixosModules.disko
  ];
  age.identityPaths = ["/state/etc/ssh/ssh_host_ed25519_key"];
}
