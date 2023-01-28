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
    config = {
      pipewire."context.properties"."default.clock.allowed-rates" = [
        44100
        48000
        88200
        96000
        176400
        192000
        358000
        384000
        716000
        768000
      ];
      pipewire-pulse."stream.properties"."resample.quality" = 15;
      client."stream.properties"."resample.quality" = 15;
      client-rt."stream.properties"."resample.quality" = 15;
    };
  };

  sound.enable = true;
}
