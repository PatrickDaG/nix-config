[
  (import ./scripts)
  (_final: prev: {
    zsh-histdb-skim = prev.callPackage ./zsh-histdb-skim.nix { };
    zsh-histdb = prev.callPackage ./zsh-histdb.nix { };
    actual = prev.callPackage ./actual.nix { };
    pr-tracker = prev.callPackage ./pr-tracker.nix { };
    homebox = prev.callPackage ./homebox.nix { };
    deploy = prev.callPackage ./deploy.nix { };
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
    kanidm = prev.kanidm.overrideAttrs (
      old:
      let
        provisionSrc = prev.fetchFromGitHub {
          owner = "oddlama";
          repo = "kanidm-provision";
          rev = "v1.1.0";
          hash = "sha256-pFOFFKh3la/sZGXj+pAM8x4SMeffvvbOvTjPeHS1XPU=";
        };
      in
      {
        patches = old.patches ++ [
          "${provisionSrc}/patches/1.2.0-oauth2-basic-secret-modify.patch"
          "${provisionSrc}/patches/1.2.0-recover-account.patch"
        ];
        passthru.enableSecretProvisioning = true;
        doCheck = false;
      }
    );
    kanidm-provision = prev.callPackage ./kanidm-provision.nix { };
    pythonPackagesExtension = prev.pythonPackagesExtension ++ [
      (_pythonFinal: pythonPrev: { usb-monitor = pythonPrev.callPackage ./usb-monitor.nix { }; })
    ];
  })
]
