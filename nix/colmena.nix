{
  self,
  nixpkgs,
  ...
} @ inputs: let
  inherit
    (nixpkgs.lib)
    filterAttrs
    mapAttrs
    flip
    ;

  nixosNodes = filterAttrs (_: x: x.type == "nixos") self.hosts;
  nodes = flip mapAttrs nixosNodes (name: hostCfg:
    import ./generate-node.nix inputs {
      inherit name;
      inherit (hostCfg) system;
      modules = [
        ../hosts/${name}
        {node.secretsDir = ../hosts/${name}/secrets;}
      ];
    });
in
  {
    meta = {
      description = "Patrick's colmena configuration(Eigenhändig geklaut von oddlama)";
      # Just a required dummy for colmena, overwritten on a per-node basis by nodeNixpkgs below.
      nixpkgs = self.pkgs.x86_64-linux;
      # This is so colmena uses the correct nixpkgs and specialarges for each host
      nodeNixpkgs = mapAttrs (_: node: node.pkgs) nodes;
      nodeSpecialArgs = mapAttrs (_: node: node.specialArgs) nodes;
    };
  }
  // mapAttrs (_: node: {inherit (node) imports;}) nodes
