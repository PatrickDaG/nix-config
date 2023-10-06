{
  pkgs,
  lib,
  minimal,
  config,
  ...
}:
lib.optionalAttrs (!minimal) {
  users.users.simon = {
    shell = pkgs.zsh;
    isNormalUser = true;
    uid = 1000;
    createHome = true;
    extraGroups = [
      "wheel"
      "audio"
      "video"
      "input"
    ];
    group = "simon";
  };
  users.groups.simon.gid = config.users.users.simon.uid;

  home-manager.users.simon = {
    imports = [
      ../common
      ../common/impermanence.nix

      ../common/programs/htop.nix
      ../common/programs/nvim
      ../common/programs/git.nix
      ../common/programs/kitty.nix
      ../common/graphical/wayland

      ./simon.nix
      ./impermanence.nix
    ];
  };
}
