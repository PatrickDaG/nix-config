{
  config,
  lib,
  pkgs,
  ...
}:
let
  nconfig = config;
in
{
  age.secrets."my-gpg-yubikey-keygrip.tar" = {
    rekeyFile = ../../secrets/gpg-keygrip.tar.age;
    group = "patrick";
    mode = "640";
  };

  hm =
    { config, ... }:
    {
      home.activation.installKeygrips = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "$HOME/.gnupg/private-keys-v1.d"
        run ${lib.getExe pkgs.gnutar} xvf ${
          lib.escapeShellArg nconfig.age.secrets."my-gpg-yubikey-keygrip.tar".path
        } -C "$HOME/.gnupg/private-keys-v1.d/"
      '';
    };
}
