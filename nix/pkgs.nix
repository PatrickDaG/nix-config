{
  inputs,
  config,
  self,
  ...
}:
{
  node.path = ../. + "/hosts";
  node.nixpkgs = self.nixpkgs-patched;

  imports = [
    (
      { lib, flake-parts-lib, ... }:
      flake-parts-lib.mkTransposedPerSystemModule {
        name = "pkgs";
        file = ./pkgs.nix;
        option = lib.mkOption { type = lib.types.unspecified; };
      }
    )
    (
      { lib, flake-parts-lib, ... }:
      flake-parts-lib.mkTransposedPerSystemModule {
        name = "pkgsCuda";
        file = ./pkgs.nix;
        option = lib.mkOption { type = lib.types.unspecified; };
      }
    )
  ];

  perSystem =
    { pkgs, system, ... }:
    let
      inherit (pkgs) lib;
    in
    {
      _module.args.pkgs = import config.node.nixpkgs {
        inherit system;
        config = {
          #allowUnfree = true;
          allowUnfreePredicate =
            # Is this not kinda stupid? I can just name a package "spotify" and now it passes?
            pkg:
            builtins.elem (lib.getName pkg) [
              # Calibre plugin to remove drm from ebooks
              "dedrm"
              # Firefox plugin to remove shit from youtube
              "youtube-recommended-videos"
              # Watch things with drm(sometimes)
              "amazon-prime-via-google-chrome"
              "netflix-via-google-chrome"
              "netflix-icon"
              "disneyplus-via-google-chrome"
              "disneyplus-logo"
              "google-chrome"
              # Firefox for zotero
              "firefox-esr-140-bin-unwrapped"
              # your_spotify needs mongodb
              "mongodb-ce"

              # Obvious
              # keep-sorted start
              "discord"
              "discord-unwrapped"
              "nvidia-settings"
              "nvidia-x11"
              "obsidian"
              "slack"
              "spotify"
              "steam"
              "steam-unwrapped"
              "zoom"
              # keep-sorted end

              # firmware
              # keep-sorted start
              "b43-firmware"
              "broadcom-bt-firmware"
              "facetimehd-calibration"
              "facetimehd-firmware"
              "intel-ocl"
              "xone-dongle-firmware"
              # keep-sorted end
            ];
          allowListedLicences = with pkgs.lib.licenses; [
          ];
          permittedInsecurePackages = [
            # for Zotero
            "firefox-esr-140-bin-unwrapped-140.17.0esr"
          ];
        };
        overlays = (import ../pkgs inputs) ++ [
          inputs.nix-topology.overlays.default
          inputs.nixos-extra-modules.overlays.default
          inputs.devshell.overlays.default
          inputs.nixvim.overlays.default
          inputs.niri.overlays.niri
          inputs.firefox-addons.overlays.default
          inputs.llm-agents.overlays.shared-nixpkgs
        ];
      };
      pkgsCuda = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.cudaSupport = true;
      };

      legacyPackages = pkgs;
      inherit pkgs;
    };
}
