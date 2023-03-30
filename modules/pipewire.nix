{
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [pulseaudio pulsemixer];

  hardware.pulseaudio.enable = lib.mkForce false;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
  };

  sound.enable = true;
}
