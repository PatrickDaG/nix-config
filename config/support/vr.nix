{ pkgs, ... }:
{
  services.monado = {
    enable = true;
    defaultRuntime = true;
  };
  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
  };
  programs.envision.enable = true;
  hm =
    { config, ... }:
    {
      home.packages = [ pkgs.wlx-overlay-s ];
      xdg.configFile."openxr/1/active_runtime.json".source =
        "${pkgs.monado}/share/openxr/1/openxr_monado.json";

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
