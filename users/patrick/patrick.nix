{pkgs, ...}: {
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
    ];
  };
}
