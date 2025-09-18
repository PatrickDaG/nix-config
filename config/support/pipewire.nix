{
  lib,
  minimal,
  pkgs,
  inputs,
  ...
}:
lib.optionalAttrs (!minimal) {
  imports = [ inputs.nix-gaming.nixosModules.pipewireLowLatency ];
  # Sadly does not seem to do anything yet
  #musnix = {
  #  enable = true;
  #  kernel= {
  #    realtime = true;
  #    packages = pkgs.linuxPackages_6_6_rt;
  #  };
  #};
  environment.systemPackages = with pkgs; [
    pulseaudio
    pulsemixer
  ];

  services.pulseaudio.enable = lib.mkForce false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
    lowLatency = {
      enable = true;
      quantum = 96;
    };
    extraConfig.pipewire."99-allowed-rates".context.properties.default.clock.allowed-rates = [
      44100
      48000
      88200
      96000
      176400
      192000
    ];
  };
}
