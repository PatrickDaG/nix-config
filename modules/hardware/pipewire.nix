{
  lib,
  minimal,
  pkgs,
  ...
}:
lib.optionalAttrs (!minimal) {
  # Sadly does not seem to do anything yet
  #musnix = {
  #  enable = true;
  #  kernel= {
  #    realtime = true;
  #    packages = pkgs.linuxPackages_6_6_rt;
  #  };
  #};
  environment.systemPackages = with pkgs; [pulseaudio pulsemixer];

  hardware.pulseaudio.enable = lib.mkForce false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
  };
  environment.etc = {
    # Allow pipewire to dynamically adjust the rate sent to the devices based on the playback stream
    "pipewire/pipewire.conf.d/99-allowed-rates.conf".text = builtins.toJSON {
      "context.properties"."default.clock.allowed-rates" = [
        44100
        48000
        88200
        96000
        176400
        192000
      ];
    };
  };

  sound.enable = false;
}
