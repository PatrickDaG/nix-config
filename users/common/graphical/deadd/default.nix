{
  imports = [
    ./deadd.nix
  ];
  services.deadd-notification-center = {
    enable = true;
    style = builtins.readFile ./style.css;
  };
}
