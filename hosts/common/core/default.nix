{
  imports = [
    ./inputrc.nix
    ./issue.nix
    ./net.nix
    ./nix.nix
    ./ssh.nix
    ./system.nix
    ./xdg.nix
    ./impermanence.nix
    ./home-manager.nix

    ../../../users/root

    ../../../modules/secrets.nix
  ];
  age.identityPaths = ["/state/etc/ssh/ssh_host_ed25519_key"];
}
