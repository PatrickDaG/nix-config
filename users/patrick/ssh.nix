{
  globals,
  lib,
  pkgs,
  ...
}:
{
  # yubikey public key parts
  hm.home.file = {
    ".ssh/1.pub".text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZixkix0KfKuq7Q19whS5FQQg51/AJGB5BiNF/7h/LM cardno:15 489 049
    '';
    ".ssh/2.pub".text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxD4GOrwrBTG4/qQhm5hoSB2CP7W9g1LPWP11oLGOjQ cardno:23 010 997
    '';
  };
  hm.home.sessionVariables.SSH_ASKPASS = lib.getExe pkgs.pinentry-gnome3;
  hm.programs.ssh = {
    enable = true;
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
        "mailnix" = {
          hostname = globals.hosts.mailnix.ip;
          user = "root";
        };

        "*" = {
          user = "root";
          identitiesOnly = true;
          inherit identityFile;
          controlMaster = "auto";
          controlPersist = "5s";
        };
      };
  };
}
