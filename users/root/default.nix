{
  pkgs,
  config,
  lib,
  minimal,
  ...
}:
{
  users.users.root = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # Patrick
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZixkix0KfKuq7Q19whS5FQQg51/AJGB5BiNF/7h/LM"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxD4GOrwrBTG4/qQhm5hoSB2CP7W9g1LPWP11oLGOjQ"
    ];
    hashedPassword = config.secrets.secrets.global.users.root.passwordHash;
  };
  imports = lib.optionals (!minimal) [

    ../patrick/alias.nix
    ../patrick/theme.nix

    ../patrick/programs/nvim
    ../patrick/programs/pager.nix
    ../patrick/programs/zsh

  ];
}
