{ globals, ... }:
{
  # yubikey public key parts
  home.file = {
    ".ssh/1.pub".text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZixkix0KfKuq7Q19whS5FQQg51/AJGB5BiNF/7h/LM cardno:15 489 049
    '';
    ".ssh/2.pub".text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxD4GOrwrBTG4/qQhm5hoSB2CP7W9g1LPWP11oLGOjQ cardno:23 010 997
    '';
  };
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings =
      let
        identityFile = [
          "~/.ssh/1.pub"
          "~/.ssh/2.pub"
        ];
      in
      {
        "mailnix" = {
          HostName = globals.hosts.mailnix.ip;
          User = "root";
        };
        "torweg" = {
          HostName = globals.hosts.torweg.ip;
          User = "root";
        };

        "*" = {
          User = "root";
          IdentitiesOnly = true;
          IdentityFile = identityFile;
          ControlMaster = "auto";
          ControlPersist = "5s";
          ControlPath = "~/.ssh/master-%r@%n:%p";
        };
      };
  };
}
