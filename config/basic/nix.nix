{
  inputs,
  stateVersion,
  pkgs,
  ...
}: {
  nix = {
    settings = {
      auto-optimise-store = true;
      allowed-users = ["@wheel"];
      trusted-users = ["root"];
      system-features = ["recursive-nix" "repl-flake" "big-parallel"];
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://ai.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
      ];
      cores = 0;
      max-jobs = "auto";
      # make agenix rekey find the secrets even without trusted user
      extra-sandbox-paths = ["/var/tmp/agenix-rekey?"];
    };
    daemonCPUSchedPolicy = "batch";
    daemonIOSchedPriority = 5;
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes recursive-nix
      flake-registry = /etc/nix/registry.json
    '';
    nixPath = ["nixpkgs=/run/current-system/nixpkgs"];
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "monthly";
    };

    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      p.flake = inputs.nixpkgs;
      pkgs.flake = inputs.nixpkgs;
      templates.flake = inputs.templates;
    };
  };
  system = {
    extraSystemBuilderCmds = ''
      ln -sv ${inputs.nixpkgs} $out/nixpkgs
    '';
  };
  programs.nix-ld.enable = true;
  system.stateVersion = stateVersion;
}
