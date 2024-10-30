{ pkgs, ... }:
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
  hm =
    { config, ... }:
    {
      home.packages = [ pkgs.wlx-overlay-s ];
      xdg.configFile."openxr/1/active_runtime.json".text = ''
        {
          "file_format_version": "1.0.0",
          "runtime": {
              "name": "Monado",
              "library_path": "${pkgs.monado}/lib/libopenxr_monado.so"
          }
        }
      '';

      xdg.configFile."openvr/openvrpaths.vrpath".text = ''
        {
          "config" :
          [
            "${config.xdg.dataHome}/Steam/config"
          ],
          "external_drivers" : null,
          "jsonid" : "vrpathreg",
          "log" :
          [
            "${config.xdg.dataHome}/Steam/logs"
          ],
          "runtime" :
          [
            "${pkgs.opencomposite}/lib/opencomposite"
          ],
          "version" : 1
        }
      '';
    };
}
