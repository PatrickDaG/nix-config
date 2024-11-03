_inputs: [
  (import ./scripts)
  (_final: prev: {
    zsh-histdb-skim = prev.callPackage ./zsh-histdb-skim.nix { };
    zsh-histdb = prev.callPackage ./zsh-histdb.nix { };
    pr-tracker = prev.callPackage ./pr-tracker.nix { };
    deploy = prev.callPackage ./deploy.nix { };
    signal-to-blog = prev.callPackage ./signal-to-blog.nix { };
    minion = prev.callPackage ./minion.nix { };
    mongodb-bin = prev.callPackage ./mongodb-bin.nix { };
    awakened-poe-trade = prev.callPackage ./awakened-poe-trade.nix { };
    neovim-clean = prev.neovim-unwrapped.overrideAttrs (
      _neovimFinal: neovimPrev: {
        nativeBuildInputs = (neovimPrev.nativeBuildInputs or [ ]) ++ [ prev.makeWrapper ];
        postInstall =
          (neovimPrev.postInstall or "")
          + ''
            wrapProgram $out/bin/nvim --add-flags "--clean"
          '';
      }
    );

    path-of-building = prev.path-of-building.overrideAttrs (old: {
      postFixup =
        (old.postFixup or "")
        + ''
          wrapProgram $out/bin/pobfrontend \
            --set QT_QPA_PLATFORM xcb
        '';
    });
  })
]
