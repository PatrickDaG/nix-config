{ pkgs, ... }:
{
  hm.home.persistence."/state".directories = [ ".config/awakened-poe-trade" ];

  hm.home.persistence."/persist".directories = [ ".local/share/pobfrontend" ];

  hm.home.packages = [
    #pkgs.awakened-poe-trade
    pkgs.path-of-building
  ];
}
