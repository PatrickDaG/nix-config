{
  hm.stylix.targets.fuzzel.enable = true;
  hm.programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        launch-prefix = "uwsm app --";
      };
    };
  };
  hm.home.persistence."/state".files = [
    ".cache/fuzzel"
  ];
}
