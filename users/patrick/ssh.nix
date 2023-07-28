{
  home.file.".ssh/1.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZixkix0KfKuq7Q19whS5FQQg51/AJGB5BiNF/7h/LM cardno:15 489 049
  '';
  home.file.".ssh/2.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxD4GOrwrBTG4/qQhm5hoSB2CP7W9g1LPWP11oLGOjQ cardno:23 010 997
  '';
  programs.ssh = {
    enable = true;
    matchBlocks = let
      identityFile = ["~/.ssh/1.pub" "~/.ssh/2.pub"];
    in {
      "elisabeth" = {
        hostname = "lel.lol";
        user = "root";
        inherit identityFile;
      };
      "patricknix" = {
        hostname = "localhost";
        user = "root";
        inherit identityFile;
      };

      "WSALVM" = {
        hostname = "172.10.8.156";
        user = "root";
        inherit identityFile;
      };

      "CompConst" = {
        hostname = "cp-service.kaist.ac.kr";
        user = "s20236085";
        port = 13001;
        inherit identityFile;
      };

      "valhalla" = {
        hostname = "valhalla.fs.tum.de";
        user = "grossmann";
        inherit identityFile;
      };
      "elisabethprivate" = {
        hostname = "lel.lol";
        user = "patrick";
        inherit identityFile;
      };
      "*.lel.lol" = {
        inherit identityFile;
      };
      "localhost" = {
        inherit identityFile;
      };
      "gitlab.lrz.de" = {
        inherit identityFile;
      };
      "github.com" = {
        inherit identityFile;
      };
      "*" = {
        identitiesOnly = true;
      };
    };
  };
}
