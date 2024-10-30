{
  pkgs,
  lib,
  config,
  ...
}:
{
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
  hm.home.persistence = {
    "/state".directories = [
      # Folders for steam
      ".local/share/Steam"
      ".steam"
      # Ken follets pillars of earth
      ".local/share//Daedalic Entertainment GmbH/"
      # Nvidia shader cache
      ".cache/nvidia"
      # Vulkan shader cache
      ".local/share/vulkan"
    ];
    "/panzer/state".directories = lib.lists.optionals (config.disko.devices.zpool ? "panzer") [
      ".local/share/SteamPanzer"
    ];
  };
}
