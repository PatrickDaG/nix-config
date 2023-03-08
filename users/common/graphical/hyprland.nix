_: {
  wayland.windowManager.hyprland = {
    enable = true;
    nvidiaPatches = true;
    extraConfig = builtins.readFile ../../../data/hyprland/config;
  };
}
