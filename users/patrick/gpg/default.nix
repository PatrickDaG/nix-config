{
  config,
  lib,
  pkgs,
  ...
}:
{
  hm.programs.gpg.publicKeys = [
    {
      source = ./pubkey.gpg;
      trust = 5;
    }
    {
      source = ./newpubkey.gpg;
      trust = 5;
    }
  ];
  # Make sure the keygrips exist, otherwise we'd need to run `gpg --card-status`
  # before being able to use the yubikey.
  hm.home.activation.installKeygrips =
    config.home-manager.users.root.lib.dag.entryAfter [ "writeBoundary" ]
      ''
        run mkdir -p "$HOME/.gnupg/private-keys-v1.d"
        run ${lib.getExe pkgs.gnutar} xvf ${
          lib.escapeShellArg config.age.secrets."my-gpg-yubikey-keygrip.tar".path
        } -C "$HOME/.gnupg/private-keys-v1.d/"
      '';
}
