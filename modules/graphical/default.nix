{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib)
    mkOption
    types
    ;
in {
  options.hidpi = mkOption {
    default = false;
    type = types.bool;
    description = "Enable HighDPI configuration for this host and all installed users";
  };
  imports = [
    inputs.stylix.nixosModules.stylix
    ./fonts.nix
    ./images.nix
  ];

  config = {
    # needed for gnome pinentry
    services.dbus.packages = [pkgs.gcr];
    stylix = {
      autoEnable = false;
      polarity = "dark";
      image = config.lib.stylix.pixel "base00";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/vice.yaml";
      # Has to be green
      override.base0B = "#00CC99";
      #base16Scheme = {
      #	base00 = "#101419";
      #	base01 = "#171B20";
      #	base02 = "#21262e";
      #	base03 = "#242931";
      #	base04 = "#485263";
      #	base05 = "#b6beca";
      #	base06 = "#dee1e6";
      #	base07 = "#e3e6eb";
      #	base08 = "#e05f65";
      #	base09 = "#f9a872";
      #	base0A = "#f1cf8a";
      #	base0B = "#78dba9";
      #	base0C = "#74bee9";
      #	base0D = "#70a5eb";
      #	base0E = "#c68aee";
      #	base0F = "#9378de";
      #};
      ## based on decaycs-dark, bright variant
      #base16Scheme = {
      #  base00 = "#101419";
      #  base01 = "#171B20";
      #  base02 = "#21262e";
      #  base03 = "#242931";
      #  base04 = "#485263";
      #  base05 = "#b6beca";
      #  base06 = "#dee1e6";
      #  base07 = "#e3e6eb";
      #  base08 = "#e5646a";
      #  base09 = "#f7b77c";
      #  base0A = "#f6d48f";
      #  base0B = "#94F7C5";
      #  base0C = "#79c3ee";
      #  base0D = "#75aaf0";
      #  base0E = "#cb8ff3";
      #  base0F = "#9d85e1";
      #};
    };
  };
}
