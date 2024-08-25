{ config, ... }:
{
  # yubikey public key parts
  home.file.".ssh/1.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZixkix0KfKuq7Q19whS5FQQg51/AJGB5BiNF/7h/LM cardno:15 489 049
  '';
  home.file.".ssh/2.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxD4GOrwrBTG4/qQhm5hoSB2CP7W9g1LPWP11oLGOjQ cardno:23 010 997
  '';
  programs.ssh = {
    enable = true;
    controlMaster = "auto";
    controlPersist = "5s";
    matchBlocks =
      let
        identityFile = [
          "~/.ssh/1.pub"
          "~/.ssh/2.pub"
        ];
      in
      {
        "elisabeth" = {
          hostname = "lel.lol";
          user = "root";
        };

        "testienix" = {
          hostname = "testienix.local";
          user = "root";
        };

        "patricknix" = {
          hostname = "patricknix.local";
          user = "root";
        };

        "maddy" = {
          hostname = config.userSecrets.hetzner_ip;
          user = "root";
        };

        "desktopnix" = {
          hostname = "desktopnix.local";
          user = "root";
        };
        "*" = {
          user = "root";
          identitiesOnly = true;
          inherit identityFile;
        };
      };
  };
}
