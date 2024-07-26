inputs:
let
  inherit (inputs) self;
  inherit (inputs.nixpkgs.lib)
    concatMapAttrs
    filterAttrs
    flip
    genAttrs
    mapAttrs'
    nameValuePair
    nixosSystem
    ;

  # Creates a new nixosSystem with the correct specialArgs, pkgs and name definition
  mkHost =
    { minimal }:
    name:
    let
      pkgs = self.pkgs.x86_64-linux;
    in
    nixosSystem {
      specialArgs = {
        # Use the correct instance lib that has our overlays
        inherit (pkgs) lib;
        inherit (self) nodes stateVersion;
        inherit inputs minimal;
      };
      modules = [
        {
          # We cannot force the package set via nixpkgs.pkgs and
          # inputs.nixpkgs.nixosModules.readOnlyPkgs, since some nixosModules
          # like nixseparatedebuginfod depend on adding packages via nixpkgs.overlays.
          # So we just mimic the options and overlays defined by the passed pkgs set.
          nixpkgs.overlays = pkgs.overlays;
          nixpkgs.config = pkgs.config;
          node.name = name;
          node.secretsDir = ../. + "/hosts/${name}/secrets";
        }
        ../hosts/${name}
      ];
    };

  # Load the list of hosts that this flake defines, which
  # associates the minimum amount of metadata that is necessary
  # to instanciate hosts correctly.
  hosts = builtins.attrNames (filterAttrs (_: type: type == "directory") (builtins.readDir ../hosts));
  # Process each nixosHosts declaration and generatea nixosSystem definitions
  nixosConfigurations = genAttrs hosts (mkHost {
    minimal = false;
  });
  minimalConfigurations = genAttrs hosts (mkHost {
    minimal = true;
  });

  # True NixOS nodes can define additional guest nodes that are built
  # together with it. We collect all defined guests from each node here
  # to allow accessing any node via the unified attribute `nodes`.
  guestConfigurations = flip concatMapAttrs self.nixosConfigurations (
    _: node:
    flip mapAttrs' (node.config.guests or { }) (
      guestName: guestDef:
      nameValuePair guestDef.nodeName (
        if guestDef.backend == "microvm" then
          node.config.microvm.vms.${guestName}.config
        else
          node.config.containers.${guestName}.nixosConfiguration
      )
    )
  );
in
{
  inherit
    hosts
    nixosConfigurations
    minimalConfigurations
    guestConfigurations
    ;
}
