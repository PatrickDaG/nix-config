{
  inputs,
  self,
  ...
}:
{
  flake.homeConfigurations.patrick = builtins.removeAttrs (
    inputs.home-manager.lib.homeManagerConfiguration
      {
        pkgs = self.pkgs.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs;
          inherit (self) globals;
        };
        modules = [ ../users/patrick/standalone.nix ];
      }
  ) [ "type" ];
}
