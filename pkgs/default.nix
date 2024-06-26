[
  (import ./scripts)
  (_self: super: {
    zsh-histdb-skim = super.callPackage ./zsh-histdb-skim.nix {};
    zsh-histdb = super.callPackage ./zsh-histdb.nix {};
    your_spotify = super.callPackage ./your_spotify.nix {};
    actual = super.callPackage ./actual.nix {};
    homebox = super.callPackage ./homebox.nix {};
    deploy = super.callPackage ./deploy.nix {};
    j-link = super.callPackage ./jlink.nix {};
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
        rev = "v1.1.0";
        hash = "sha256-pFOFFKh3la/sZGXj+pAM8x4SMeffvvbOvTjPeHS1XPU=";
      };
    in {
      patches =
        old.patches
        ++ [
          "${provisionSrc}/patches/1.2.0-oauth2-basic-secret-modify.patch"
          "${provisionSrc}/patches/1.2.0-recover-account.patch"
        ];
      passthru.enableSecretProvisioning = true;
      doCheck = false;
    });
    pythonPackagesExtensions =
      super.pythonPackagesExtensions
      ++ [
        (pythonFinal: _pythonPrev: {
          jaxlib = pythonFinal.callPackage ./jaxlib.nix {};
        })
      ];
    kanidm-provision = super.callPackage ./kanidm-provision.nix {};
  })
]
