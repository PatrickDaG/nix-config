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
    hashedPassword = config.secrets.secrets.global.users.simon.passwordHash;
    autoSubUidGidRange = false;
  };
  users.groups.simon.gid = config.users.users.simon.uid;
  programs.dconf.enable = true;

  home-manager.users.simon = {
    imports = [
      ../common
      ../common/impermanence.nix

      ../common/programs/htop.nix
      ../common/programs/direnv.nix
      ../common/programs/firefox.nix
      ../common/programs/nvim
      ../common/programs/gdb.nix
      ../common/programs/git.nix
      ../common/programs/kitty.nix
      ../common/graphical/wayland
      ../common/graphical/Xorg

      ./simon.nix
      ./impermanence.nix
      ./ssh.nix
    ];
  };
}
