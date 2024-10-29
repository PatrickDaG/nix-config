{
  # can't play VR until https://github.com/hyprwm/Hyprland/pull/8116 is merged
  services.monado = {
    enable = true;
    defaultRuntime = true;
  };
  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
  };
}
