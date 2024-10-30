{ pkgs, ... }:
{
  hm.home.persistence."/persist".directories = [ ".local/share/PrismLauncher" ];
  hm.home.packages = [ pkgs.prismlauncher ];
}
