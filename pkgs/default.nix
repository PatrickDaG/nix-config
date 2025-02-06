_inputs: [
  (import ./scripts)
  (_final: prev: {
    zsh-histdb-skim = prev.callPackage ./zsh-histdb-skim.nix { };
    zsh-histdb = prev.callPackage ./zsh-histdb.nix { };
    signal-to-blog = prev.callPackage ./signal-to-blog.nix { };
    firezone = prev.callPackage ./firezone.nix { };
    ytdlp-pot-provider = prev.callPackage ./ytdlp-pot-provider.nix { };
    mongodb-bin = prev.callPackage ./mongodb-bin.nix { };
    disneyplus = prev.callPackage ./disney.nix { };
    amazon = prev.callPackage ./amazon.nix { };
    nix-plugins = prev.callPackage ./nix-plugins.nix { };
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
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (_pythonFinal: _pythonPrev: {
      })
    ];

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
