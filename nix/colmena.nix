{
  self,
  nixpkgs,
  ...
} @ inputs: let
  inherit
    (nixpkgs.lib)
    filterAttrs
    mapAttrs
    ;

  nixosNodes = filterAttrs (_: x: x.type == "nixos") self.hosts;
  nodes = mapAttrs (import ./generate-node.nix inputs) nixosNodes;
  generateColmenaNode = nodeName: _: {
    inherit (nodes.${nodeName}) imports;
  };
in
  {
    meta = {
      description = "Patrick's colmena configuration(Eigenhändig geklaut von oddlama";
      # Just a required dummy for colmena, overwritten on a per-node basis by nodeNixpkgs below.
      nixpkgs = self.pkgs.x86_64-linux;
      # This is so colmena uses the correct nixpkgs and specialarges for each host
      nodeNixpkgs = mapAttrs (_: node: node.pkgs) nodes;
      nodeSpecialArgs = mapAttrs (_: node: node.specialArgs) nodes;
    };
  }
  // mapAttrs generateColmenaNode nodes
