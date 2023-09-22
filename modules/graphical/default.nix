{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.stylix.nixosModules.stylix
    ./fonts.nix
  ];

  stylix = {
    autoEnable = false;
    polarity = "dark";
    image = config.lib.stylix.pixel "base00";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/helios.yaml";
    override = {
      base00 = "#000000";
    };
  };
}
