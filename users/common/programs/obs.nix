{pkgs, ...}: {
  programs.obs-studio = {
    enable = false;
    plugins = with pkgs.obs-studio-plugins; [
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi
      obs-nvfbc
    ];
  };
}
