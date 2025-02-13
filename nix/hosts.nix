{ self, ... }:
{
  node.path = ../. + "/hosts";
  node.nixpkgs = self.nixpkgs-patched;
}
