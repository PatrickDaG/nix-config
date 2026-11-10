{
  pkgs,
  lib,
  config,
  ...
}:
{
  # programs.gamescope = {
  #   enable = true;
  #   # Not possible inside steam
  #   #capSysNice = true;
  # };
  boot.kernelModules = lib.optionals config.programs.steam.enable [ "nvidia_uvm" ]; # needed for cs2
  services.ratbagd.enable = config.programs.steam.enable;
  hm.home.packages = lib.optionals config.programs.steam.enable [ pkgs.piper ];
  programs.steam = {
    enable = config.node.name == "desktopnix";
    # This takes 1.5 GB because it seems to pull in a full nixpkgs clone?
    # extraCompatPackages = [
    #   pkgs.proton-ge-bin
    # ];
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
    enable = config.programs.steam.enable;
    settings = {
      general.renice = 10;
    };
  };
  users.users.patrick.extraGroups = lib.optionals config.programs.gamemode.enable [ "gamemode" ];
}
