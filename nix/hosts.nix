{ inputs, self, ... }:
{
  node.path = ../. + "/hosts";
  node.nixpkgs = self.nixpkgs-patched;
  flake =
    { config, ... }:
    {
      wireguardEvalCache = config.pkgs.x86_64-linux.lib.wireguard.createEvalCache inputs [
        "services"
        "monitoring"
      ];
    };
}
