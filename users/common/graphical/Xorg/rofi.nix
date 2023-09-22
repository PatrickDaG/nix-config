{
  stylix.targets.rofi.enable = true;
  programs.rofi = {
    enable = true;
    extraConfig = {
      matching = "fuzzy";
      dpi = 1;
    };
  };
}
