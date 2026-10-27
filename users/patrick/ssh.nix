{ globals, lib, ... }:
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
        atlasHosts = {
          atlas101 = "172.31.1.16";
          atlas102 = "172.31.1.17";
          atlas103 = "172.31.1.18";
          atlas104 = "172.31.1.19";
          atlas105 = "172.31.1.20";
          atlas106 = "172.31.1.21";
          atlas107 = "172.31.1.22";
          atlas108 = "172.31.1.23";
          atlas109 = "172.31.1.24";
          atlas110 = "172.31.1.25";
          atlas111 = "172.31.1.26";
          atlas112 = "172.31.1.27";
          atlas113 = "172.31.1.28";
          atlas114 = "172.31.1.29";
          atlas115 = "172.31.1.30";
          atlas116 = "172.31.1.31";
          atlas117 = "172.31.1.32";
          atlas118 = "172.31.1.33";
          atlas119 = "172.31.1.34";
          atlas120 = "172.31.1.35";
          atlas201 = "172.31.1.48";
          atlas202 = "172.31.1.49";
          atlas203 = "172.31.1.50";
          atlas204 = "172.31.1.51";
          atlas205 = "172.31.1.52";
          atlas206 = "172.31.1.53";
          atlas207 = "172.31.1.54";
          atlas208 = "172.31.1.55";
          atlas209 = "172.31.1.56";
          atlas210 = "172.31.1.57";
          atlas211 = "172.31.1.58";
          atlas212 = "172.31.1.59";
          atlas213 = "172.31.1.60";
          atlas214 = "172.31.1.61";
          atlas215 = "172.31.1.62";
          atlas216 = "172.31.1.63";
          atlas217 = "172.31.1.64";
          atlas218 = "172.31.1.65";
          atlas219 = "172.31.1.66";
          atlas220 = "172.31.1.67";
        };
      in
      {
        atlas11 = lib.hm.dag.entryBefore [ "atlas-final-match" ] {
          HostName = "atlas11.mpi-sp.org";
          User = "jump";
          ForwardAgent = true;
        };
        atlas-final-match = {
          header = ''Match final host "172.31.1.*" !host "172.31.1.12"'';
          User = "ubuntu";
          ProxyJump = "atlas11";
          ForwardAgent = true;
        };

        "*.local" = {
          ForwardAgent = true;
        };
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
      }
      // lib.mapAttrs (
        _: hostName: lib.hm.dag.entryBefore [ "atlas-final-match" ] { HostName = hostName; }
      ) atlasHosts;
  };
}
