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
} @ inputs: nodeName: {configPath ? null, ...} @ nodeMeta: let
  path = ../hosts + "/${nodeName}/";
  nodePath =
    if configPath == null && builtins.isPath path && nixpkgs.lib.pathIsDirectory path
    then path
    else if configPath != null
    then configPath
    else null;
in {
  inherit (nodeMeta) system;
  pkgs = self.pkgs.${nodeMeta.system};
  specialArgs = {
    inherit (nixpkgs) lib;
    inherit (self) nodes stateVersion;
    inherit inputs;
    inherit nodeName;
    inherit nodeMeta;
    inherit hyprland;
    inherit nodePath;
    nixos-hardware = nixos-hardware.nixosModules;
    impermanence = impermanence.nixosModules;
  };
  imports =
    [
      home-manager.nixosModules.default
      impermanence.nixosModules.impermanence
      agenix.nixosModules.default
      agenix-rekey.nixosModules.default
    ]
    ++ nixpkgs.lib.optional (nodePath != null) nodePath;
}
