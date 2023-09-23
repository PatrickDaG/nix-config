{
  lib,
  pkgs,
  ...
}: {
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
    # Nixos wiki copied
    "pipewire/pipewire.conf.d/92-low-latency.conf".text = ''
      context.properties = {
        default.clock.rate = 48000
        default.clock.quantum = 32
        default.clock.min-quantum = 32
        default.clock.max-quantum = 32
      }
    '';
    "pipewire/pipewire-pulse.d/91-low-latency.conf".text = builtins.toJSON {
      context.modules = [
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            pulse.min.req = "32/48000";
            pulse.default.req = "32/48000";
            pulse.max.req = "32/48000";
            pulse.min.quantum = "32/48000";
            pulse.max.quantum = "32/48000";
          };
        }
      ];
      stream.properties = {
        node.latency = "32/48000";
        resample.quality = 1;
      };
    };

    # If resampling is required, use a higher quality. 15 is overkill and too cpu expensive without any obvious audible advantage
    "pipewire/pipewire-pulse.conf.d/99-resample.conf".text = builtins.toJSON {
      "stream.properties"."resample.quality" = 10;
    };
    "pipewire/client.conf.d/99-resample.conf".text = builtins.toJSON {
      "stream.properties"."resample.quality" = 10;
    };
    "pipewire/client-rt.conf.d/99-resample.conf".text = builtins.toJSON {
      "stream.properties"."resample.quality" = 10;
    };
  };

  sound.enable = false;
}
