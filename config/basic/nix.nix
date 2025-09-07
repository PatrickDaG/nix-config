{
  inputs,
  ...
}:
{
  nix = {
    #package = pkgs.lixPackageSets.latest.lix;
    channel.enable = false;
    settings = {
      auto-optimise-store = true;
      allowed-users = [ "@wheel" ];
      trusted-users = [
        "root"
        "@nix-build"
      ];
      system-features = [
        "repl-flake"
        "big-parallel"
      ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://ai.cachix.org"
        "https://nix-gaming.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        (builtins.readFile ../../secrets/nix-key.pub)
        # configuration.nix
      ];
      cores = 0;
      max-jobs = "auto";
      # make agenix rekey find the secrets even without trusted user
      extra-sandbox-paths = [ "/var/tmp/agenix-rekey?" ];
      log-lines = 25;
    };
    daemonCPUSchedPolicy = "batch";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 5;

    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes
      flake-registry = /etc/nix/registry.json
    '';
    nixPath = [ "nixpkgs=/run/current-system/nixpkgs" ];
    optimise.automatic = true;
    gc = {
      # collect garbage(oddlama for example)
      automatic = true;
      dates = "weekly";
    };

    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      p.flake = inputs.nixpkgs;
      pkgs.flake = inputs.nixpkgs;
      templates.flake = inputs.templates;
    };
  };
  hm.xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
      segger-jlink.acceptLicense = true;
    }

  '';
  system = {
    extraSystemBuilderCmds = ''
      ln -sv ${inputs.nixpkgs} $out/nixpkgs
    '';
  };
  programs.nix-ld.enable = true;
  system.stateVersion = "24.05";

  systemd.services.nix-gc.serviceConfig = {
    CPUSchedulingPolicy = "batch";
    IOSchedulingClass = "idle";
    IOSchedulingPriority = 7;
  };

  # Make builds to be more likely killed than important services.
  # 100 is the default for user slices and 500 is systemd-coredumpd@
  # We rather want a build to be killed than our precious user sessions as builds can be easily restarted.
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = 250;
}
