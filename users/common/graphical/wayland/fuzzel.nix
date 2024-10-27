{
  stylix.targets.fuzzel.enable = true;
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        launch-preix = "uwsm app --";
      };
    };
  };
}
