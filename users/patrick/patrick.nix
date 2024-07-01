{
  pkgs,
  lib,
  nixosConfig,
  ...
}: {
  images.enable = true;
  home = {
    packages = with pkgs; [
      nextcloud-client
      discord
      webcord
      netflix
      xournalpp
      galaxy-buds-client
      thunderbird
      signal-desktop
      telegram-desktop
      chromium
      python3
      jq
      osu-lazer-bin
      mumble
      zotero
      timer

      ocaml
      dune_3
      ocamlformat # formatter
      ocamlPackages.ocaml-lsp
      ocamlPackages.utop
      ocamlPackages.mparser
      ocamlPackages.ounit2
      ocamlPackages.qcheck

      via

      figlet
      cowsay
      cmatrix
    ];
  };
  # Make sure the keygrips exist, otherwise we'd need to run `gpg --card-status`
  # before being able to use the yubikey.
  home.activation.installKeygrips = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p "$HOME/.gnupg/private-keys-v1.d"
    run ${lib.getExe pkgs.gnutar} xvf ${lib.escapeShellArg nixosConfig.age.secrets."my-gpg-yubikey-keygrip.tar".path} -C "$HOME/.gnupg/private-keys-v1.d/"
  '';
}
