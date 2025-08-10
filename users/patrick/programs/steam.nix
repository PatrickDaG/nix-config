{
  pkgs,
  lib,
  config,
  ...
}:
{
  programs.gamescope = {
    enable = true;
    # Not possible inside steam
    #capSysNice = true;
  };
  services.ratbagd.enable = true;
  hm.home.packages = [ pkgs.piper ];
  programs.steam = {
    enable = true;
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
    extraPackages = [
      # vampir überlebende braucht diese pkgs
      pkgs.libgdiplus
      pkgs.cups
    ];
    platformOptimizations.enable = true;
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
  programs.gamemode = {
    enable = true;
    settings = {
      general.renice = 10;
    };
  };
  users.users.patrick.extraGroups = [ "gamemode" ];
}
