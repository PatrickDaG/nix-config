[
  (import ./scripts)
  (_prev: final: {
    zsh-histdb-skim = final.callPackage ./zsh-histdb-skim.nix { };
    zsh-histdb = final.callPackage ./zsh-histdb.nix { };
    actual = final.callPackage ./actual.nix { };
    pr-tracker = final.callPackage ./pr-tracker.nix { };
    homebox = final.callPackage ./homebox.nix { };
    deploy = final.callPackage ./deploy.nix { };
    mongodb-bin = final.callPackage ./mongodb-bin.nix { };
    awakened-poe-trade = final.callPackage ./awakened-poe-trade.nix { };
    neovim-clean = final.neovim-unwrapped.overrideAttrs (
      _neovimFinal: neovimPrev: {
        nativeBuildInputs = (neovimPrev.nativeBuildInputs or [ ]) ++ [ final.makeWrapper ];
        postInstall =
          (neovimPrev.postInstall or "")
          + ''
            wrapProgram $out/bin/nvim --add-flags "--clean"
          '';
      }
    );
    path-of-building = final.path-of-building.overrideAttrs (old: {
      postFixup =
        (old.postFixup or "")
        + ''
          wrapProgram $out/bin/pobfrontend \
            --set QT_QPA_PLATFORM xcb
        '';
    });
    kanidm = final.kanidm.overrideAttrs (
      old:
      let
        provisionSrc = final.fetchFromGitHub {
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
    kanidm-provision = final.callPackage ./kanidm-provision.nix { };
  })
]
