{pkgs, ...}: {
  home.persistence."/persist".directories = [
    ".local/share/PrismLauncher"
  ];
  home.packages = [
    pkgs.prismlauncher
  ];
}
