{
  environment = {
    variables.BROWSER = "echo";
    stub-ld.enable = false;
  };

  documentation.nixos.enable = false;
  fonts.fontconfig.enable = false;
  programs.command-not-found.enable = false;

  xdg.autostart.enable = false;
  xdg.icons.enable = false;
  xdg.menus.enable = false;
  xdg.mime.enable = false;
  xdg.sounds.enable = false;
}
