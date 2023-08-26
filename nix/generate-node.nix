{
  self,
  colmena,
  home-manager,
  impermanence,
  nixos-hardware,
  nixpkgs,
  agenix,
  agenix-rekey,
  hyprland,
  ...
} @ inputs: {
  name,
  # Additional modules to import
  modules ? [],
  system,
  ...
}: {
  inherit system;
  pkgs = self.pkgs.${system};
  specialArgs = {
    inherit (self.pkgs.${system}) lib;
    inherit (self) nodes stateVersion;
    inherit
      inputs
      ;
  };
  imports =
    modules ++ [{node.name = name;}];
}
