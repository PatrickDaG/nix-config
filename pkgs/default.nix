[
  (import ./scripts)
  (_self: super: {
    zsh-histdb-skim = super.callPackage ./zsh-histdb-skim.nix {};
    zsh-histdb = super.callPackage ./zsh-histdb.nix {};
    your_spotify = super.callPackage ./your_spotify.nix {};
    deploy = super.callPackage ./deploy.nix {};
    minify = super.callPackage ./minify {};
    mongodb-bin = super.callPackage ./mongodb-bin.nix {};
    awakened-poe-trade = super.callPackage ./awakened-poe-trade.nix {};
    neovim-clean = super.neovim-unwrapped.overrideAttrs (_neovimFinal: neovimPrev: {
      nativeBuildInputs = (neovimPrev.nativeBuildInputs or []) ++ [super.makeWrapper];
      postInstall =
        (neovimPrev.postInstall or "")
        + ''
          wrapProgram $out/bin/nvim --add-flags "--clean"
        '';
    });
    kanidm = super.kanidm.overrideAttrs (old: let
      provisionSrc = super.fetchFromGitHub {
        owner = "oddlama";
        repo = "kanidm-provision";
        rev = "aa7a1c8ec04622745b385bd3b0462e1878f56b51";
        hash = "sha256-NRolS3l2kARjkhWP7FYUG//KCEiueh48ZrADdCDb9Zg=";
      };
    in {
      patches =
        old.patches
        ++ [
          "${provisionSrc}/patches/${old.version}-oauth2-basic-secret-modify.patch"
          "${provisionSrc}/patches/${old.version}-recover-account.patch"
        ];
      passthru.enableSecretProvisioning = true;
      doCheck = false;
    });
    kanidm-provision = super.callPackage ./kanidm-provision.nix {};
  })
]
