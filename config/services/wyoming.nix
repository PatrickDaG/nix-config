{ pkgs, ... }:
{
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/wyoming";
      mode = "0700";
    }
  ];

  services.wyoming.faster-whisper = {
    servers.hass = {
      enable = true;
      # see https://github.com/rhasspy/rhasspy3/blob/master/programs/asr/faster-whisper/script/download.py
      model = "base-int8";
      language = "de";
      uri = "tcp://0.0.0.0:10300";
      device = "cpu";
    };
  };

  services.wyoming.piper = {
    # German inference needs neither voice training nor Japanese dictionaries or HTTP/alignment extras.
    package = pkgs.wyoming-piper.override {
      piper-tts = pkgs.piper-tts.override {
        withAlignment = false;
        withHTTP = false;
        withJapanese = false;
        withTrain = false;
      };
    };
    servers.hass = {
      enable = true;
      # https://rhasspy.github.io/piper-samples/
      voice = "de_DE-thorsten-high";
      uri = "tcp://0.0.0.0:10200";
    };
  };
}
