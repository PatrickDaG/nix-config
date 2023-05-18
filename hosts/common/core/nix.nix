{
  pkgs,
  inputs,
  ...
}: {
  nix = {
    settings = {
      auto-optimise-store = true;
      allowed-users = ["@wheel"];
      trusted-users = ["root" "@wheel"];
      system-features = ["recursive-nix"];
      substituters = [
        "https://nix-config.cachix.org"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
        "https://colmena.cachix.org"
      ];
      trusted-public-keys = [
        "nix-config.cachix.org-1:Vd6raEuldeIZpttVQfrUbLvXJHzzzkS0pezXCVVjDG4="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
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
            plugin-files = ${pkgs.nix-plugins}/lib/nix/plugins
      extra-builtins-file = ${../../..}/nix/extra-builtins.nix
    '';
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
  # TODO unify the stateversions here and of homemanager
  system.stateVersion = "23.05";
}
