{
  hm.stylix.targets.rofi.enable = true;
  hm.programs.rofi = {
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
