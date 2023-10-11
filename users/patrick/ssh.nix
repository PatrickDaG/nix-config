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
    matchBlocks = let
      identityFile = ["~/.ssh/1.pub" "~/.ssh/2.pub"];
    in {
      "elisabeth" = {
        hostname = "lel.lol";
        user = "root";
      };

      "gojo" = {
        hostname = "10.181.97.217";
        user = "root";
      };

      "patricknix" = {
        hostname = "patricknix.local";
        user = "root";
      };

      "testienix" = {
        hostname = "testienix.local";
        user = "root";
      };

      "desktopnix" = {
        hostname = "desktopnix.local";
        user = "root";
      };

      "valhalla" = {
        hostname = "valhalla.fs.tum.de";
        user = "grossmann";
      };
      "elisabethprivate" = {
        hostname = "lel.lol";
        user = "patrick";
      };
      "*" = {
        identitiesOnly = true;
        inherit identityFile;
      };
    };
  };
}
