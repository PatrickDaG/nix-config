{
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
  ];
  age.identityPaths = ["/state/etc/ssh/ssh_host_ed25519_key"];
}
