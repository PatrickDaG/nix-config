{inputs, ...}: {
  imports = [
    ./boot.nix
    ./efi.nix
    ./fonts.nix
    ./home-manager.nix
    ./inputrc.nix
    ./issue.nix
    ./net.nix
    ./nix.nix
    ./ssh.nix
    ./system.nix
    ./xdg.nix

    ../../users/root

    ../secrets.nix
    ../meta.nix
    ../smb-mounts.nix
    ../impermanence

    inputs.home-manager.nixosModules.default
    inputs.impermanence.nixosModules.impermanence
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.nixseparatedebuginfod.nixosModules.default
  ];
  age.identityPaths = ["/state/etc/ssh/ssh_host_ed25519_key"];
}
