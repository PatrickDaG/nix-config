{
  inputs,
  stateVersion,
  ...
}: {
  nix = {
    settings = {
      auto-optimise-store = true;
      allowed-users = ["@wheel" "nixseparatedebuginfod"];
      trusted-users = ["root" "@wheel"];
      system-features = ["recursive-nix" "repl-flake" "big-parallel"];
      substituters = [
        "https://nix-config.cachix.org"
        "https://nix-community.cachix.org"
        "https://colmena.cachix.org"
        "https://cache.nixos.org"
        "https://nixpkgs-wayland.cachix.org"
      ];
      trusted-public-keys = [
        "nix-config.cachix.org-1:Vd6raEuldeIZpttVQfrUbLvXJHzzzkS0pezXCVVjDG4="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      ];
      cores = 0;
      max-jobs = "auto";
    };
    daemonCPUSchedPolicy = "batch";
    daemonIOSchedPriority = 5;
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes recursive-nix
      flake-registry = /etc/nix/registry.json
    '';
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "daily";
    };

    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      p.flake = inputs.nixpkgs;
      pkgs.flake = inputs.nixpkgs;
      templates.flake = inputs.templates;
    };
  };
  system.stateVersion = stateVersion;
}
