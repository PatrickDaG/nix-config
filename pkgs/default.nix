[
  (import ./scripts)
  (_self: super: {
    zsh-histdb-skim = super.callPackage ./zsh-histdb-skim.nix {};
    zsh-histdb = super.callPackage ./zsh-histdb.nix {};
    deploy = super.callPackage ./deploy.nix {};
    formats =
      super.formats
      // {
        ron = import ./ron.nix {inherit (super) lib pkgs;};
      };
  })
]
