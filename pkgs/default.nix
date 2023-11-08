[
  (import ./scripts)
  (_self: super: {
    zsh-histdb-skim = super.callPackage ./zsh-histdb-skim.nix {};
    zsh-histdb = super.callPackage ./zsh-histdb.nix {};
    deploy = super.callPackage ./deploy.nix {};
    minify = super.callPackage ./minify {};
    neovim-clean = super.neovim-unwrapped.overrideAttrs (_neovimFinal: neovimPrev: {
      nativeBuildInputs = (neovimPrev.nativeBuildInputs or []) ++ [super.makeWrapper];
      postInstall =
        (neovimPrev.postInstall or "")
        + ''
          wrapProgram $out/bin/nvim --add-flags "--clean"
        '';
    });
    formats =
      super.formats
      // {
        ron = import ./ron.nix {inherit (super) lib pkgs;};
      };
  })
]
