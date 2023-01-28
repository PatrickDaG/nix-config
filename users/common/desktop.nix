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
    xclip
  ];
  home.sessionVariables = {
    # Firefox touch support
    "MOZ_USE_XINPUT2" = 1;
    # Firefox Hardware render
    "MOZ_WEBRENDER" = 1;
  };
}
