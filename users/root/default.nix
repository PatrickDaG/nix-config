{
  pkgs,
  config,
  ...
}: {
  rekey.secrets.root.file = ../../secrets/root.passwd.age;
  users.users.root = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDZixkix0KfKuq7Q19whS5FQQg51/AJGB5BiNF/7h/LM"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxD4GOrwrBTG4/qQhm5hoSB2CP7W9g1LPWP11oLGOjQ"
    ];
    passwordFile = config.rekey.secrets.root.path;
  };
  home-manager.users.root = {
    imports = [../common];
  };
}
