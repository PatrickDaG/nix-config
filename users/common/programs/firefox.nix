{
  home = {
    sessionVariables = {
      # Firefox touch support
      MOZ_USE_XINPUT2 = 1;
      # Firefox Hardware render
      MOZ_WEBRENDER = 1;
      LIBVA_DRIVER_NAME = "nvidia";
      NVD_BACKEND = "direct";
      MOZ_DISABLE_RDD_SANDBOX = 1;
    };
  };
  programs.firefox.enable = true;
  home.persistence."/state".directories = [
    ".cache/mozilla"
    ".mozilla"
  ];
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "text/html" = ["firefox.desktop"];
    "text/xml" = ["firefox.desktop"];
    "x-scheme-handler/http" = ["firefox.desktop"];
    "x-scheme-handler/https" = ["firefox.desktop"];
  };
}
