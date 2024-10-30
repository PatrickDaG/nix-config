{
  stylix.targets.rofi.enable = true;
  programs.rofi = {
    enable = true;
    extraConfig = {
      matching = "fuzzy";
      dpi = 1;
    };
  };
  hm.home.persistence."/state".files = [
    ".cache/rofi3.druncache"
  ];
}
