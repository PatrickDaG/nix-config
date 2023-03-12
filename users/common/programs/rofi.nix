{pkgs, ...}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = "DarkBlue";
    extraConfig = {
      matching = "fuzzy";
      dpi = 1;
    };
  };
}
