{ inputs, ... }:
{
  flake =
    { config, lib, ... }:
    let
      inherit (lib)
        concatMapAttrs
        filterAttrs
        flip
        genAttrs
        mapAttrs'
        nameValuePair
        ;

      # Creates a new nixosSystem with the correct specialArgs, pkgs and name definition
      mkHost =
        { minimal }:
        name:
        let
          pkgs = config.pkgs.x86_64-linux;
          stateVersion = "23.05";
        in
        inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {
            # Use the correct instance lib that has our overlays
            inherit (pkgs) lib;
            inherit (config) nodes;
            inherit inputs minimal stateVersion;
          };
          modules = [
            {
              # We cannot force the package set via nixpkgs.pkgs and
              # inputs.nixpkgs.nixosModules.readOnlyPkgs, since some nixosModules
              # like nixseparatedebuginfod depend on adding packages via nixpkgs.overlays.
              # So we just mimic the options and overlays defined by the passed pkgs set.
              node.name = name;
              node.secretsDir = ../. + "/hosts/${name}/secrets";
              nixpkgs.overlays = (import ../pkgs inputs) ++ [
                # nixpkgs-wayland.overlay
                inputs.nixos-extra-modules.overlays.default
                inputs.nix-topology.overlays.default
                inputs.devshell.overlays.default
                inputs.agenix-rekey.overlays.default
                inputs.nixvim.overlays.default
              ];
              nixpkgs.config.allowUnfree = true;
            }
            ../hosts/${name}
          ];
        };

      # Load the list of hosts that this flake defines, which
      # associates the minimum amount of metadata that is necessary
      # to instanciate hosts correctly.
      hosts = builtins.attrNames (filterAttrs (_: type: type == "directory") (builtins.readDir ../hosts));
    in
    # Process each nixosHosts declaration and generatea nixosSystem definitions
    {
      nixosConfigurations = genAttrs hosts (mkHost {
        minimal = false;
      });
      minimalConfigurations = genAttrs hosts (mkHost {
        minimal = true;
      });

      # True NixOS nodes can define additional guest nodes that are built
      # together with it. We collect all defined guests from each node here
      # to allow accessing any node via the unified attribute `nodes`.
      guestConfigurations = flip concatMapAttrs config.nixosConfigurations (
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
      # All nixosSystem instanciations are collected here, so that we can refer
      # to any system via nodes.<name>
      nodes = config.nixosConfigurations // config.guestConfigurations;
    };
}
