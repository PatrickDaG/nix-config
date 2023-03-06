{
  description = "Patrick tolles flake template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpks,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpks {inherit system;};
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          st
        ];
      };
    });
}
