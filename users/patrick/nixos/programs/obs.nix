{ pkgs, ... }:
{
  hm.programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      #obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi
      # TODO reenable
      #obs-nvfbc
    ];
  };
  hm.home.persistence."/state".directories = [
    ".config/obs-studio"
  ];
}
