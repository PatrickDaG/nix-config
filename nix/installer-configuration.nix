{ pkgs, ... }:
{
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  console = {
    keyMap = "de-latin1-nodeadkeys";
  };

  users.users.root = {
    password = "nixos";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZixkix0KfKuq7Q19whS5FQQg51/AJGB5BiNF/7h/LM"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxD4GOrwrBTG4/qQhm5hoSB2CP7W9g1LPWP11oLGOjQ"
    ];
  };

  environment = {
    variables.EDITOR = "nvim";
    systemPackages = with pkgs; [
      neovim
      git
      parted
      ripgrep
      bat
      curl
    ];
    etc.issue.text = ''
      Gey
    '';
  };
}
