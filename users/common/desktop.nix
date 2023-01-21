{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    zathura
    pinentry
    arandr
    feh
  ];
}
