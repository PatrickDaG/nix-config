{
  lib,
  minimal,
  pkgs,
  ...
}:
lib.optionalAttrs (!minimal) {
  programs.gpu-screen-recorder.enable = true;
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraPkgs =
        pkgs: with pkgs; [
          # vampir überlebende braucht diese pkgs
          libgdiplus
          cups
        ];
    };
  };
}
