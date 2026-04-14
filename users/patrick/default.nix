{
  pkgs,
  globals,
  lib,
  minimal,
  ...
}:
lib.optionalAttrs (!minimal) {
  primaryUser = "patrick";
  users.users.patrick = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # Patrick
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZixkix0KfKuq7Q19whS5FQQg51/AJGB5BiNF/7h/LM"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxD4GOrwrBTG4/qQhm5hoSB2CP7W9g1LPWP11oLGOjQ"
    ];
    isNormalUser = true;
    createHome = true;
    extraGroups = [
      "wheel"
      "dialout"
      "plugdev"
      "audio"
      "video"
      "input"
      "cdrom"
      "disk"
      # TPM settings
      "tss"
      "davfs2"
    ];
    group = "patrick";
    inherit (globals.users.patrick) hashedPassword;
    autoSubUidGidRange = false;
    subUidRanges = [
      {
        count = 65534;
        startUid = 100001;
      }
    ];
    subGidRanges = [
      {
        count = 65534;
        startGid = 100001;
      }
    ];
  };
  users.groups.patrick = { };

  environment.systemPackages = with pkgs; [
    # xournalpp needs this or else it will crash
    adwaita-icon-theme
  ];

  programs.dconf.enable = true;

  imports = [

    ./alias.nix
    ./dev.nix
    ./impermanence.nix
    ./patrick.nix
    ./smb.nix
    ./ssh.nix
    ./theme.nix

    ./wayland

    ./programs/bottles.nix
    ./programs/direnv.nix
    ./programs/firefox.nix
    ./programs/gdb.nix
    ./programs/git.nix
    ./programs/gpg
    ./programs/htop.nix
    ./programs/kitty.nix
    ./programs/nvim
    ./programs/pager.nix
    ./programs/poe.nix
    ./programs/spicetify.nix
    ./programs/steam.nix
    ./programs/thunderbird.nix
    ./programs/zsh
    # Currently unused and need a lot of space
    #./programs/minecraft.nix
    #./programs/obs.nix
    #./programs/minion.nix
    #./programs/gpu-screen-recorder.nix
    #./programs/yt-dlp.nix

  ];

}
