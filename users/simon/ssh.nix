{
  # yubikey public key parts
  home.file.".ssh/1.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZixkix0KfKuq7Q19whS5FQQg51/AJGB5BiNF/7h/LM cardno:15 489 049
  '';
  programs.ssh = {
    enable = true;
    controlMaster = "auto";
    controlPersist = "5s";
    matchBlocks = let
      identityFile = ["~/.ssh/1.pub"];
    in {
      "elisabeth" = {
        hostname = "lel.lol";
        user = "root";
      };

      "gojo" = {
        hostname = "gojo.local";
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
        user = "hanssen";
      };
      "elisabethprivate" = {
        hostname = "lel.lol";
        user = "simon";
      };
      "binex" = {
        hostname = "praksrv.sec.in.tum.de";
        user = "team402";
      };
      "*" = {
        identitiesOnly = true;
        inherit identityFile;
      };
    };
  };
}
