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
} @ inputs: nodeName: nodeMeta: {
  inherit (nodeMeta) system;
  pkgs = self.pkgs.${nodeMeta.system};
  specialArgs = {
    inherit (nixpkgs) lib;
    inherit (self) nodes;
    inherit inputs;
    inherit nodeName;
    inherit nodeMeta;
    inherit hyprland;
    nodePath = ../hosts + "/${nodeName}/";
    secrets = self.secrets.content;
    nodeSecrets = self.secrets.content.nodes.${nodeName};
    nixos-hardware = nixos-hardware.nixosModules;
    impermanence = impermanence.nixosModules;
  };
  imports = [
    (../hosts + "/${nodeName}")
    home-manager.nixosModules.default
    impermanence.nixosModules.impermanence
    agenix.nixosModules.default
    agenix-rekey.nixosModules.default
    #]
    #++ optionals nodeMeta.microVmHost [
    #  microvm.nixosModules.host
    #]
    #++ optionals (nodeMeta.type == "microvm") [
    #  microvm.nixosModules.microvm
  ];
}
