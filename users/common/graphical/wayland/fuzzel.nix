{
  stylix.targets.fuzzel.enable = true;
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        launch-prefix = "uwsm app --";
      };
    };
  };
}
